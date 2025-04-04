import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

import 'models/models.dart';

class FirebaseRoomRepository {
  final Logger log = Logger(printer: SimplePrinter());

  final Dio esClient;
  
  late final FirebaseFirestore firestoreInstance;
  late final CollectionReference<Map<String, dynamic>> roomsCollection;
  
  FirebaseRoomRepository({
    required this.esClient
  }) {
    firestoreInstance = FirebaseFirestore.instance;
    roomsCollection = firestoreInstance.collection("rooms");
  }

  /// Fetches a single [Room] stream.
  Stream<Room> getRoomStream(String roomId) {
    log.i("getRoomStream() invoked...");

    try {
      var rs = roomsCollection
        .doc(roomId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) =>
          Room.fromDocument(snapshot.data()!)
        );
      
      log.i("Room stream fetching successful");
      return rs;
    } catch (e) {
      log.e("Room stream fetching failed, error: $e");
      throw Exception(e);
    }
  }

  /// Fetches [Message]s [List] stream.
  Stream<List<Message>> getMessagesStream(String roomId) {
    log.i("getMessagesStream() invoked...");
    
    try {
      var ms = roomsCollection
        .doc(roomId)
        .collection("messages")
        .orderBy(
          "timestamp",
          descending: true
        )
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.docs.map(
            (doc) => Message.fromDocument(doc.data())
          ).toList()
        );

      log.i("Room stream fetching successful");
      return ms;
    } catch (e) {
      log.e("Messages stream fetching failed, error: $e");
      throw Exception(e);
    }
  }

  /// Fetches a Stream with [Room]s [List] that the user with id [userId] is apart of.
  Stream<List<Room>> getUserRooms(String userId) {
    log.i("getUserRooms() invoked...");

    try {
      // Manages the combined output
      StreamController<List<Room>> controller = StreamController.broadcast();

      // Combined streams
      StreamSubscription? membersSub;
      StreamSubscription? roomsSub;

      membersSub = firestoreInstance
        .collectionGroup("members")
        .where("memberId", isEqualTo: userId)
        .snapshots()
        .listen((querySnapshot) {
          log.i("Handling room members data...");

          List<String> roomsIds = querySnapshot.docs
            .map((doc) => doc.data()["roomId"] as String)
            .toList();

          if (roomsIds.isEmpty) {
            controller.add([]);
            return;
          }

          roomsSub = roomsCollection
            .where(FieldPath.documentId, whereIn: roomsIds)
            .orderBy("lastMessageTimestamp", descending: true)
            .snapshots()
            .listen((roomSnapshot) {
              log.i("Handling user rooms data...");

              // Mapping documents to Room objects
              List<Room> rooms = roomSnapshot.docs
                .map<Room>((doc) => Room.fromDocument(doc.data()))
                .toList();

              controller.add(rooms);
            });
        });

      // Cleaning up after cancel
      controller.onCancel = () {
        membersSub?.cancel();
        roomsSub?.cancel();
        controller.close();

        log.w("User rooms controller cleaned up");
      };

      return controller.stream;
    } on FirebaseException catch (e) {
      log.e("Fetching user rooms error: $e");
      throw Exception(e);
    }
  }

  /// Adds a new room to the firebase rooms collection.
  /// If [isPrivate] equals true then the newly created room is a private chat room.
  /// Else it is a group chat room room.
  /// [roomName] can be set for group chat room creation.
  /// [privateRoomMembers] has to be provided for private rooms.
  /// Returns a [String] room id.
  Future<String> createRoom(bool isPrivate, [String? roomName, List<Map<String, dynamic>>? privateRoomMembers]) async {
    log.i("createRoom() invoked...");

    try {  
      DocumentReference roomRef = roomsCollection.doc();

      var room = isPrivate
        ? Room.emptyPrivateChatRoom.copyWith(id: roomRef.id)
        : Room.emptyGroupChatRoom.copyWith(id: roomRef.id, isPrivate: false, name: roomName);

      await roomRef.set(room.toDocument());

      if (isPrivate) {
        await esClient.put(
          "/rooms/_doc/${room.id}",
          data: room.toEsObject()..addAll({
            "firstMember": privateRoomMembers![0],
            "secondMember": privateRoomMembers[1]
          })
        );
      } else {
        await esClient.put(
          "/rooms/_doc/${room.id}",
          data: room.toEsObject()
        );
      }


      log.i("Room creation successful, room id: ${roomRef.id}");
      return roomRef.id;
    } on DioException catch (e) {
      log.e("Room creation failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Room creation failed: $e");
      throw Exception(e);
    }
  }

  /// Adds a new message to the firebase messages subcollection and to elasticsearch.
  /// Updates rooms collection data related to the latest message.
  Future<void> addMessage(String roomId, Message message) async {
    try {
      CollectionReference<Map<String, dynamic>> messagesCollection = roomsCollection.doc(roomId).collection("messages");
      
      DocumentReference docRef = messagesCollection.doc();

      var msg = message.copyWith(id: docRef.id);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.set(docRef, msg.toDocument());

      batch.set(
        roomsCollection.doc(roomId),
        {
          "lastMessageContent": message.content,
          "lastMessageHasPicture": message.picture.isEmpty ? false : true,
          "lastMessageSenderId": message.senderId,
          "lastMessageTimestamp": message.timestamp
        },
        SetOptions(merge: true)
      );

      await batch.commit();

      var ndjsonData = [
        { "index": { "_index": "messages", "_id": msg.id } },
        msg.toEsObject(roomId),
        { "update": { "_index": "rooms", "_id": roomId } },
        {
          "doc": {
            "lastMessageContent": msg.content,
            "lastMessageHasPicture": msg.picture.isNotEmpty,
            "lastMessageSenderId": msg.senderId,
            "lastMessageTimestamp": msg.timestamp.toDate().toIso8601String()
          }
        }
      ];
      
      // await esClient.bulkRequest(ndjsonData); // TODO i could include es_client_repository and use this here and in user repo but idk

      await esClient.post(
        "/_bulk",
        data: "${ndjsonData.map(jsonEncode).join("\n")}\n",
        options: Options(
          headers: { "Content-Type": "application/x-ndjson" }
        )
      );

      log.i("Adding message \"$message\" successful");
    } on DioException catch (e) {
      log.e("Adding message \"$message\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Adding message \"$message\" failed: $e");
      throw Exception(e);
    }
  }

  /// Updates a room in the firestore.
  Future<void> updateRoom(Room updatedRoom) async {
    log.i("updateRoom() invoked...");

    try {
      await roomsCollection.doc(updatedRoom.id).update(updatedRoom.toDocument());

      await esClient.post(
        "/rooms/_update/${updatedRoom.id}",
        data: {
          "doc": updatedRoom.toEsObject(),
          "doc_as_upsert": true
        }
      );

      log.i("Room update successful");
    } on DioException catch (e) {
      log.e("Room update failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Room update failed: $e");
      throw Exception(e);
    }
  }

  /// Function for strictly adding and updating room pictures.
  /// The picture is stored inside firebase storage and it's download URL is stored inside firebase firestore.
  Future<void> uploadRoomPicture(String roomId, String imagePath) async {
    log.i("uploadRoomPicture() invoked...");

    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        "Rooms/$roomId/ChatPictures/${roomId}_pic"
      );

      File imageFile = File(imagePath);

      await firebaseStorageRef.putFile(imageFile);

      String picUrl = await firebaseStorageRef.getDownloadURL();

      await roomsCollection.doc(roomId).update({
        "picture": picUrl
      });

      await esClient.post(
        "/rooms/_update/$roomId",
        data: {
          "doc": {
            "picture": picUrl
          }
        }
      );

      log.i("Uploading room picture for room with id: \"$roomId\" successful");
    } on DioException catch (e) {
      log.e("Uploading room picture for room with id: \"$roomId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Uploading room picture for room with id: \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Updates a message in the firestore
  Future<void> updateMessage(String roomId, Message updatedMsg) async {
    log.i("updateMessage() invoked...");

    try {
      await roomsCollection.doc(roomId).collection("messages").doc(updatedMsg.id).update(updatedMsg.toDocument());

      await esClient.post(
        "/messages/_update/${updatedMsg.id}",
        data: {
          "doc": updatedMsg.toEsObject(roomId),
          "doc_as_upsert": true
        }
      );

      // TODO update room info also in ES, in general fix this method to account for proper updates to rooms data if the message is the latest one
      // TODO might need to include lastMessageId in rooms data for that to work :|

      log.i("Message update successful");
    } on DioException catch (e) {
      log.e("Message update failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Message update failed: $e");
      throw Exception(e);
    }
  }

  /// Deletes a room from to the firebase rooms collection.
  Future<void> deleteRoom(String roomId) async {
    log.i("deleteRoom() invoked...");

    try {
      await roomsCollection.doc(roomId).delete();

      await esClient.delete("/rooms/_doc/$roomId");

      log.i("Room deletion with id \"$roomId\" successful");
    } on DioException catch (e) {
      log.e("Room deletion with id \"$roomId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Room deletion with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Deletes a message from the firebase messages subcollection.
  Future<void> deleteMessage(String roomId, String messageId) async { // TODO don't remember here what i thought to do but adjust ES at least and UI
    log.i("deleteMessage() invoked...");

    try {
      await roomsCollection.doc(roomId).collection("messages").doc(messageId).delete();

      await esClient.delete("/messages/_doc/$messageId");

      log.i("Message deletion with id \"$messageId\" successful");
    } on DioException catch (e) {
      log.e("Message deletion with id \"$messageId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Message deletion with id \"$messageId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Adds members to the room.
  /// If [newMembersIds] is equal to one, only one member gets added, otherwise it is handled with bulk requests.
  /// [newMembers] is optional, used for denormalization in elasticsearch and should be null if private chat room is handled.
  Future<void> addMembersToRoom(String roomId, List<String> newMembersIds, [List<Map<String, dynamic>>? newMembers]) async {
    log.i("addMembersToRoom() invoked...");

    try {
      if (newMembersIds.isEmpty) throw ArgumentError("newMembersId list can't be empty");

      CollectionReference<Map<String, dynamic>> membersRef = roomsCollection.doc(roomId).collection("members");

      var mem = Member(roomId: roomId, memberId: newMembersIds[0]);

      if (newMembersIds.length == 1) {
        await membersRef.doc(newMembersIds[0]).set(mem.toDocument());

        if (newMembers != null) {
          await esClient.put(
            "/members/_doc/$roomId${newMembersIds[0]}",
            data: mem.toEsObject(newMembers[0]["name"], newMembers[0]["picture"])
          );
        }
      } else {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        List<Map<String, dynamic>> ndjsonData = [];

        for (int i = 0; i < newMembersIds.length; i++) {
          DocumentReference<Map<String, dynamic>> newMemberRef = membersRef.doc(newMembersIds[i]);
          
          var mem = Member(roomId: roomId, memberId: newMembersIds[i]);

          batch.set(newMemberRef, mem.toDocument());

          if (newMembers != null) {
            ndjsonData.addAll([
              { "index": { "_index": "members", "_id": "$roomId${newMembersIds[i]}" } },
              mem.toEsObject(newMembers[i]["name"], newMembers[i]["picture"])
            ]);
          }
        }

        await batch.commit();

        if (ndjsonData.isNotEmpty) {
          await esClient.post(
            "/_bulk",
            data: "${ndjsonData.map(jsonEncode).join("\n")}\n",
            options: Options(
              headers: { "Content-Type": "application/x-ndjson" }
            )
          );
        }
      }

      log.i("Adding members to room with id \"$roomId\" successful");
    } on DioException catch (e) {
      log.e("Adding members to room with id \"$roomId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Adding members to room with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Handles kicking out a member with id [memberId] out of a group chat room with id [roomId].
  Future<void> kickOutRoomMember(String memberId, String roomId) async {
    log.i("kickOutRoomMember() invoked...");

    try {
      var kickOutTimeDoc = { "kickOutTime": Timestamp.now() };

      await roomsCollection.doc(roomId).collection("members").doc(memberId).update(kickOutTimeDoc);
      
      esClient.put(
        "/members/_update/$roomId$memberId",
        data: {
          "doc": kickOutTimeDoc
        }
      );

      log.i("Kicking out member with id \"$memberId\" from room with id \"$roomId\" successful");
    } on DioException catch (e) {
      log.e("Kicking out member with id \"$memberId\" from room with id \"$roomId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Kicking out member with id \"$memberId\" from room with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Searches for rooms through elasticsearch by [query] using n-grams.
  /// Pagination is allowed with [searchAfterContent] parameter that stores search_after.
  /// If [pitId] is null, it will inject new PIT for data consistency.
  /// Returns a tuple with [List] of [String] ids, isPrivate [bool]s, names and pictures urls of type [String].
  /// Name and picture url values are dependent on whether the room is private or not (either room values or private chat room friend values).
  /// On top of that PIT id and search_after content.
  Future<(List<(String, bool, String, String)>, String, List<dynamic>?)> searchChatRooms(
    String query,
    String currUserId,
    String? pitId,
    List<dynamic>? searchAfterContent
  ) async {
    log.i("searchChatRooms() invoked...");
    
    try {
      String keepAliveMinutes = "1m";
      bool isInitial = pitId == null;

      if (isInitial) {
        var rPitRes = await esClient.post("/rooms/_pit?keep_alive=$keepAliveMinutes");
        pitId = rPitRes.data["id"];
      }

      var rSearchRes = await esClient.get(
        "/_search",
        data: {
          "size": 20,
          "pit": {
            "id": pitId,
            "keep_alive": keepAliveMinutes
          },
          "query": {
            "bool": {
              "should": [
                {
                  "bool": {
                    "must": [
                      {
                        "bool": {
                          "must": [
                            { "term": { "isPrivate": true } }
                          ],
                          "should": [
                            { "match_phrase": { "firstMember.name": query } },
                            { "match_phrase": { "secondMember.name": query } }
                          ],
                          "minimum_should_match": 1,
                          "must_not": [
                            {
                              "bool": {
                                "must_not": [
                                  {
                                    "bool": {
                                      "must": [
                                        { "match_phrase": { "firstMember.name": query } },
                                        { "match_phrase": { "secondMember.name": query } },
                                      ]
                                    }
                                  }
                                ],
                                "must": [
                                  { "match_phrase": { "firstMember.name": query } },
                                  { "term": { "firstMember.id": currUserId } }
                                ]
                              }
                            },
                            {
                              "bool": {
                                "must_not": [
                                  {
                                    "bool": {
                                      "must": [
                                        { "match_phrase": { "firstMember.name": query } },
                                        { "match_phrase": { "secondMember.name": query } },
                                      ]
                                    }
                                  }
                                ],
                                "must": [
                                  { "match_phrase": { "secondMember.name": query } },
                                  { "term": { "secondMember.id": currUserId } }
                                ]
                              }
                            }
                          ]
                        }
                      },
                      {
                        "bool": {
                          "should": [
                            { "term": { "firstMember.id": currUserId } },
                            { "term": { "secondMember.id": currUserId } }
                          ]
                        }
                      }
                    ]
                  }
                },
                {
                  "bool": {
                    "must": [
                      { "term": { "isPrivate": false } },
                      { "match_phrase": { "name": query } }
                    ]
                  }
                }
              ]
            }
          },
          "script_fields": {
            "room": {
              "script": {
                "source": """
                  if (doc['isPrivate'].value) {
                    String currUserId = params.currUserId;
                    if (doc['firstMember.id'].value == currUserId) {
                      return [doc['id'].value, doc['isPrivate'].value,
                        doc['secondMember.name.keyword'].value, doc['secondMember.picture'].value];
                    } else {
                      return [doc['id'].value, doc['isPrivate'].value,
                        doc['firstMember.name.keyword'].value, doc['firstMember.picture'].value];
                    }
                  } else {
                    return [doc['id'].value, doc['isPrivate'].value, doc['name.keyword'].value, doc['picture'].value];
                  }
                """,
                "params": { "currUserId": currUserId }
              }
            }
          },
          "_source": false,
          "fields": ["room"],
          "sort": [
            {
              "_script": {
                "type": "string",
                "script": {
                  "source": """
                    if (doc['isPrivate'].value) {
                      String currUserId = params.currUserId;
                      if (doc['firstMember.id'].value == currUserId) {
                        return doc['secondMember.name.keyword'].value;
                      } else {
                        return doc['firstMember.name.keyword'].value;
                      }
                    } else {
                      return doc['name.keyword'].value;
                    }
                  """,
                  "params": { "currUserId": currUserId },
                },
                "order": "asc"
              }
            },
            { "lastMessageTimestamp": "desc" },
            { "id": "asc" } // For uniqueness
          ],
          if (searchAfterContent != null) "search_after": searchAfterContent
        }
      );

      List<dynamic> rHits = rSearchRes.data["hits"]["hits"];
      if (rHits.isEmpty) {
        log.i("Searching for chat rooms successful -> no values found");
        return (<(String, bool, String, String)>[], pitId!, searchAfterContent);
      }

      List<(String, bool, String, String)> usrMatches = rHits.map((hit) {
        var room = hit["fields"]["room"];
        return (room[0] as String, room[1] as bool, room[2] as String, room[3] as String);
      }).toList();

      searchAfterContent = rHits.isNotEmpty ? rHits.last["sort"] : null;

      log.i("Searching for chat rooms successful");
      return (usrMatches, pitId!, searchAfterContent);
    } on DioException catch (e) {
      log.e("Searching for chat rooms failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Searching for chat rooms failed: $e");
      throw Exception(e);
    }
  }

  /// Performs a full-text search for messages through elasticsearch by [query] inside room with id [roomId].
  /// Pagination is allowed with [searchAfterContent] parameter that stores search_after.
  /// If [pitId] is null, it will inject new PIT for data consistency.
  /// Returns a tuple with [List] of [Message]s, senders' [String] names and picture urls, PIT id and search_after content.
  Future<(List<(Message, String, String, String?)>, String, List<dynamic>?)> searchMessages(
    String query,
    String currUserId,
    String roomId,
    String? pitId,
    List<dynamic>? searchAfterContent
  ) async {
    log.i("searchMessages() invoked...");
    
    try {
      String keepAliveMinutes = "1m";
      bool isInitial = pitId == null;

      if (isInitial) {
        var mPitRes = await esClient.post("/messages/_pit?keep_alive=$keepAliveMinutes");
        pitId = mPitRes.data["id"];
      }

      var mSearchRes = await esClient.get(
        "/_search",
        data: {
          "size": 20,
          "pit": {
            "id": pitId,
            "keep_alive": keepAliveMinutes
          },
          "query": {
            "bool": {
              "must": [
                { "term": { "roomId": roomId } },
                {
                  "match": {
                    "content": {
                      "query": query,
                      "fuzziness": "auto"
                    }
                  }
                }
              ]
            }
          },
          "highlight": {
            "fields": {
              "content": {}
            }
          },
          "_source": ["id", "edited", "content", "picture", "senderId", "timestamp"],
          "sort": [
            { "timestamp": "desc" },
            { "id": "asc" } // For uniqueness
          ],
          if (searchAfterContent != null) "search_after": searchAfterContent
        }
      );

      List<dynamic> mHits = mSearchRes.data["hits"]["hits"];
      if (mHits.isEmpty) {
        log.i("Searching for messages successful -> no values found");
        return (<(Message, String, String, String?)>[], pitId!, searchAfterContent);
      }

      List<Message> messagesMatches = mHits.map((hit) => Message.fromEsObject(hit["_source"])).toList();

      var sSearchRes = await esClient.get(
        "/users/_search",
        data: {
          "size": 20,
          "query": {
            "bool": {
              "filter": [
                { "terms": { "id": messagesMatches.map((msg) => msg.senderId).toList() } }
              ]
            }
          },
          "_source": ["id", "name", "picture"]
        }
      );

      List<dynamic> sHits = sSearchRes.data["hits"]["hits"];

      Map<String, (String, String)> senderMap = {};
      for (var s in sHits) {
        var src = s["_source"];
        senderMap[src["id"]] = (src["name"], src["picture"]);
      }

      List<(Message, String, String, String?)> retVals = [];
      for (var msm in messagesMatches) {
        String? highlightedContent = mHits.firstWhere(
          (hit) => hit["_source"]["id"] == msm.id,
          orElse: () => {"highlight": {}}
        )["highlight"]?["content"]?.first;
        
        retVals.add((msm, senderMap[msm.senderId]!.$1, senderMap[msm.senderId]!.$2, highlightedContent));
      }

      searchAfterContent = mHits.last["sort"];

      log.i("Searching messages for room with id \"$roomId\" successful");
      return (retVals, pitId!, searchAfterContent);
    } on DioException catch (e) {
      log.e("Searching for messages failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Searching for messages failed: $e");
      throw Exception(e);
    }
  }

  /// Searches for members through elasticsearch by [query] using n-grams inside room with id [roomId].
  /// Pagination is allowed with [searchAfterContent] parameter that stores search_after.
  /// If [pitId] is null, it will inject new PIT for data consistency.
  /// Returns a tuple with [List] of [Member]s, members' names and picture urls, PIT id and search_after content.
  Future<(List<(Member, String, String)>, String, List<dynamic>?)> searchGroupMembers(
    String query,
    String currUserId,
    String roomId,
    String? pitId,
    List<dynamic>? searchAfterContent
  ) async {
    log.i("searchGroupMembers() invoked...");
    
    try {
      String keepAliveMinutes = "1m";
      bool isInitial = pitId == null;

      if (isInitial) {
        var mPitRes = await esClient.post("/members/_pit?keep_alive=$keepAliveMinutes");
        pitId = mPitRes.data["id"];
      }

      var mSearchRes = await esClient.get(
        "/_search",
        data: {
          "size": 20,
          "pit": {
            "id": pitId,
            "keep_alive": keepAliveMinutes
          },
          "query": {
            "bool": {
              "must": [
                { "term": { "roomId": roomId } },
                { "match_phrase": { "member.name": query } }
              ]
            }
          },
          "sort": [
            { "member.name": "asc" },
            { "timestamp": "desc" },
            { "id": "asc" } // For uniqueness
          ],
          if (searchAfterContent != null) "search_after": searchAfterContent
        }
      );

      List<dynamic> mHits = mSearchRes.data["hits"]["hits"];
      if (mHits.isEmpty) {
        log.i("Searching for members for room with id \"$roomId\" successful -> no values found");
        return (<(Member, String, String)>[], pitId!, searchAfterContent);
      }

      List<(Member, String, String)> membersMatches = mHits.map((hit) {
        var src = hit["_source"];
        return (Member.fromEsObject(src), src["member.name"] as String, src["member.picture"] as String);
      }).toList();

      searchAfterContent = mHits.isNotEmpty ? mHits.last["sort"] : null;

      log.i("Searching for members for room with id \"$roomId\" successful");
      return (membersMatches, pitId!, searchAfterContent);
    } on DioException catch (e) {
      log.e("Searching for members for room with id \"$roomId\" failed: ${e.response}");
      throw Exception(e);
    } catch (e) {
      log.e("Searching for members for room with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }
}
