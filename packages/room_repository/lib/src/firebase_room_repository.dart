import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';
import 'util/chat_room_tuple.dart';

class FirebaseRoomRepository {
  final roomsCollection = FirebaseFirestore.instance.collection("rooms");

  /// Fetches a single room with all it's data and messages.
  Future<ChatRoomTuple> getRoomWithMessages(String roomId) async {
    Room room = await roomsCollection.doc(roomId).get().then((value) =>
      Room.fromDocument(value.data()!)
    );

    List<Message> messages = await roomsCollection.doc(roomId).collection("messages").get().then((value) =>
      value.docs.map<Message>(
        (doc) => Message.fromDocument(doc.data())
      ).toList()
    );

    return ChatRoomTuple(
      room: room,
      messages: messages
    );
  }

  /// Fetches a [Room]s [List] that the user with id [userId] is apart of.
  Future<List<Room>> getUserRooms(String userId) async {
    return await roomsCollection.where(
      "members",
      arrayContains: userId
    ).get().then((value) => 
      value.docs.map<Room>(
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
    await roomsCollection.doc(roomId).collection("messages").add(message.toDocument());
  }

  /// Updates a room in the firestore.
  Future<void> updateRoomData(String roomId, Room updatedRoom) async {
    await roomsCollection.doc(roomId).update(updatedRoom.toDocument());
  }

  /// Updates a message in the firestore
  Future<void> updateMessage(String roomId, String messageId, Message updatedMsg) async {
    await roomsCollection.doc(roomId).collection("messages").doc(messageId).update(updatedMsg.toDocument());
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
