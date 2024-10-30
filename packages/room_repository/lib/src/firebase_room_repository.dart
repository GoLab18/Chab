import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'models/models.dart';
import 'util/chat_room_tuple.dart';

class FirebaseRoomRepository {
  late final FirebaseFirestore firestoreInstance;
  late final CollectionReference<Map<String, dynamic>> roomsCollection;
  
  FirebaseRoomRepository() {
    firestoreInstance = FirebaseFirestore.instance;
    roomsCollection = firestoreInstance.collection("rooms");
  }

  /// Fetches a single room with a [Message]s [List] Stream.
  Future<ChatRoomTuple> getRoomWithMessages(String roomId) async {
    Room room = await roomsCollection.doc(roomId).get().then((value) =>
      Room.fromDocument(value.data()!)
    );
    
    Stream<List<Message>> messagesStream = roomsCollection
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

    return ChatRoomTuple(
      room: room,
      messagesStream: messagesStream
    );
  }

  /// Fetches a Stream with [Room]s [List] that the user with id [userId] is apart of.
  Future<Stream<List<Room>>> getUserRooms(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestoreInstance
        .collectionGroup("members")
        .where("userId", isEqualTo: userId)
        .get();

      List<String> roomsIds = querySnapshot
        .docs
        .map((doc) =>
          doc.data()["roomId"] as String
        )
        .toList();

      return roomsIds.isEmpty
        ? Stream.value([])
        : roomsCollection
        .where(
          FieldPath.documentId,
          whereIn: roomsIds
        )
        .orderBy(
          "lastMessageTimestamp",
          descending: true
        )
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.docs.map<Room>(
            (doc) => Room.fromDocument(doc.data())
          ).toList()
        );
      
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  /// Adds a new room to the firebase rooms collection.
  /// If isPrivate equals true then the newly created room is a private chat room.
  /// Else it is a group chat room room.
  Future<String> createRoom(bool isPrivate) async {
     DocumentReference<Map<String, dynamic>> roomRef;

    if (isPrivate) {
      roomRef = await roomsCollection.add(Room.emptyPrivateChatRoom.toDocument());
    } else {
      roomRef = await roomsCollection.add(Room.emptyGroupChatRoom.toDocument());
    }

    return roomRef.id;
  }

  /// Adds a new message to the firebase messages subcollection.
  Future<void> addMessage(String roomId, Message message) async {
    // Get a reference to the messages subcollection
    CollectionReference<Map<String, dynamic>> messagesCollection = roomsCollection.doc(roomId).collection("messages");
    
    // Generate a new document reference (contains the ID that will be stored in it).
    DocumentReference docRef = messagesCollection.doc();

    // Set the message with the ID.
    await docRef.set(message.copyWith(id: docRef.id).toDocument());

    // Make it the latest message in the chat room.
    await roomsCollection.doc(roomId).set({
      'lastMessageContent': message.content,
      'lastMessageHasPicture': message.picture.isEmpty ? false : true,
      "lastMessageSenderId": message.senderId,
      'lastMessageTimestamp': message.timestamp
    }, SetOptions(merge: true));
  }

  /// Updates a room in the firestore.
  Future<void> updateRoom(Room updatedRoom) async {
    await roomsCollection.doc(updatedRoom.id).update(updatedRoom.toDocument());
  }

  /// Function for strictly adding and updating room pictures.
  /// The picture is stored inside firebase storage and it's download URL is stored inside firebase firestore.
  Future<void> uploadRoomPicture(String roomId, String imagePath) async {
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
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Updates a message in the firestore
  Future<void> updateMessage(String roomId, Message updatedMsg) async {
    await roomsCollection.doc(roomId).collection("messages").doc(updatedMsg.id).update(updatedMsg.toDocument());
  }

  /// Deletes a room from to the firebase rooms collection.
  Future<void> deleteRoom(String roomId) async {
    await roomsCollection.doc(roomId).delete();
  }

  /// Deletes a message from the firebase messages subcollection.
  Future<void> deleteMessage(String roomId, String messageId) async {
    await roomsCollection.doc(roomId).collection("messages").doc(messageId).delete();
  }

  /// Adds members to the room.
  /// If [newMembersIds] is equal to one, only one member gets added.
  /// [isGroupChatRoom] flag is for storing additional data for each member. 
  /// Throws on an empty [newMembersIds] list.
  Future<void> addMembersToRoom(bool isGroupChatRoom, String roomId, List<String> newMembersIds) async {
    if (newMembersIds.isEmpty) throw Exception("newMembersId list cannot be empty");

    CollectionReference<Map<String, dynamic>> membersRef = roomsCollection.doc(roomId).collection("members");

    if (newMembersIds.length == 1) {
      await membersRef.doc(newMembersIds[0]).set({
        "roomId": roomId,
        "userId": newMembersIds[0],
        if (isGroupChatRoom) "isMemberStill": true
      });

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
  }
}
