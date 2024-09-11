import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

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
  Stream<List<Room>> getUserRooms(String userId) async* {
    yield* roomsCollection
      .where(
        "members",
        arrayContains: userId
      )
      .orderBy(
        "lastMessageTimestamp",
        descending: true
      )
      .limit(20)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snapshot) => 
        snapshot.docs.map<Room>(
          (doc) => Room.fromDocument(doc.data())
        ).toList()
      );
  }

  /// Adds a new room to the firebase rooms collection.
  Future<void> addRoom(Room room) async {
    await roomsCollection.add(room.toDocument());
  }

  /// Adds a new message to the firebase messages subcollection.
  Future<void> addMessage(String roomId, Message message) async {
    // Get a reference to the messages subcollection
    CollectionReference<Map<String, dynamic>> messagesCollection = roomsCollection.doc(roomId).collection("messages");
    
    // Generate a new document reference (contains the ID that will be stored in it).
    DocumentReference docRef = messagesCollection.doc();

    // Set the message with the ID.
    await docRef.set(message.copyWith(id: docRef.id).toDocument());
  }

  /// Updates a room in the firestore.
  Future<void> updateRoomData(String roomId, Room updatedRoom) async {
    await roomsCollection.doc(roomId).update(updatedRoom.toDocument());
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
}
