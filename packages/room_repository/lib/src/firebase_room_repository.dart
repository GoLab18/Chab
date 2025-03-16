import 'dart:async';
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
  /// If isPrivate equals true then the newly created room is a private chat room.
  /// Else it is a group chat room room.
  Future<String> createRoom(bool isPrivate) async {
    log.i("createRoom() invoked...");

    try {  
      DocumentReference roomRef = roomsCollection.doc();

      var room = isPrivate
        ? Room.emptyPrivateChatRoom.copyWith(id: roomRef.id)
        : Room.emptyGroupChatRoom.copyWith(id: roomRef.id);

      await roomRef.set(room.toDocument());

      await esClient.put(
        "rooms/_doc/${room.id}",
        data: room.toEsObject()
      );

      log.i("Room creation successful, room id: ${roomRef.id}");
      return roomRef.id;
    } catch (e) {
      log.e("Room creation failed");
      throw Exception(e);
    }
  }

  /// Adds a new message to the firebase messages subcollection.
  Future<void> addMessage(String roomId, Message message) async {
    try {
      // Get a reference to the messages subcollection
      CollectionReference<Map<String, dynamic>> messagesCollection = roomsCollection.doc(roomId).collection("messages");
      
      // Generate a new document reference (contains the ID that will be stored in it).
      DocumentReference docRef = messagesCollection.doc();

      var msg = message.copyWith(id: docRef.id);

      // Set the message with the ID.
      await docRef.set(msg.toDocument());

      // Make it the latest message in the chat room.
      await roomsCollection.doc(roomId).set({
        'lastMessageContent': message.content,
        'lastMessageHasPicture': message.picture.isEmpty ? false : true,
        "lastMessageSenderId": message.senderId,
        'lastMessageTimestamp': message.timestamp
      }, SetOptions(merge: true));

      await esClient.put(
        "messages/_doc/${msg.id}",
        data: msg.toEsObject()
      );
      
      log.i("Adding message \"$message\" successful");
    } catch (e) {
      log.e("Adding message \"$message\" failed");
      throw Exception(e);
    }
  }

  /// Updates a room in the firestore.
  Future<void> updateRoom(Room updatedRoom) async {
    log.i("updateRoom() invoked...");

    try {
      await roomsCollection.doc(updatedRoom.id).update(updatedRoom.toDocument());

      await esClient.post(
        "rooms/_update/${updatedRoom.id}",
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
        "rooms/_update/$roomId",
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
        "messages/_update/${updatedMsg.id}",
        data: {
          "doc": updatedMsg.toEsObject(),
          "doc_as_upsert": true
        }
      );

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
  Future<void> deleteMessage(String roomId, String messageId) async {
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
  /// If [newMembersIds] is equal to one, only one member gets added.
  /// [isGroupChatRoom] flag is for storing additional data for each member. 
  /// Throws on an empty [newMembersIds] list.
  Future<void> addMembersToRoom(bool isGroupChatRoom, String roomId, List<String> newMembersIds) async {
    log.i("addMembersToRoom() invoked...");

    try {
      if (newMembersIds.isEmpty) throw Exception("newMembersId list cannot be empty");

      CollectionReference<Map<String, dynamic>> membersRef = roomsCollection.doc(roomId).collection("members");

      if (newMembersIds.length == 1) {
        await membersRef.doc(newMembersIds[0]).set({
          "roomId": roomId,
          "userId": newMembersIds[0],
          if (isGroupChatRoom) "isMemberStill": true        // TODO what about this isMemberStill (?)
        });

        log.i("Adding members to room with id \"$roomId\" successful");
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String memberId in newMembersIds) {
        DocumentReference<Map<String, dynamic>> newMemberRef = membersRef.doc(memberId);
        
        batch.set(newMemberRef, {
          "roomId": roomId,
          "userId": memberId
        });
      }

      await batch.commit();

      log.i("Adding members to room with id \"$roomId\" successful");
    } catch (e) {
      log.e("Adding members to room with id \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }
}
