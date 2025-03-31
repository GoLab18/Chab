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
        .where("userId", isEqualTo: userId)
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
        msg.toEsObject(),
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

      await esClient.post(
        "/_bulk",
        data: "${ndjsonData.map(jsonEncode).join("\n")}\n",
        options: Options(
          headers: { "Content-Type": "application/x-ndjson" }
        )
      );

      log.i("Adding message \"$message\" successful");
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
          "doc": updatedMsg.toEsObject(),
          "doc_as_upsert": true
        }
      );

      // TODO update room info also in ES, in general fix this method to account for proper updates to rooms data if the message is the latest one
      // TODO might need to include lastMessageId in rooms data for that to work :|

      log.i("Message update successful");
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
      if (newMembersIds.isEmpty) throw Exception("newMembersId list can't be empty");

      CollectionReference<Map<String, dynamic>> membersRef = roomsCollection.doc(roomId).collection("members");

      if (newMembersIds.length == 1) {
        await membersRef.doc(newMembersIds[0]).set({
          "roomId": roomId,
          "userId": newMembersIds[0]
        });

        if (newMembers != null) {
          esClient.put(
            "/members/_doc/$roomId${newMembersIds[0]}",
            data: {
              "roomId": roomId,
              "member": newMembers[0]
            }
          );
        }
      } else {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        List<Map<String, dynamic>> ndjsonData = [];

        for (int i = 0; i < newMembersIds.length; i++) {
          DocumentReference<Map<String, dynamic>> newMemberRef = membersRef.doc(newMembersIds[i]);
          
          batch.set(newMemberRef, {
            "roomId": roomId,
            "userId": newMembersIds[i]
          });

          if (newMembers != null) {
            ndjsonData.addAll([
              { "index": { "_index": "members", "_id": newMembersIds[i] } },
              newMembers[i]
            ]);
          }
        }

        await batch.commit();

        if (newMembers != null) {
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
    } catch (e) {
      log.e("Adding members to room with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }
}
