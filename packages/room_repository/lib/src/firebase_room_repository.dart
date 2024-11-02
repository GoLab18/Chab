import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

import 'models/models.dart';

class FirebaseRoomRepository {
  final Logger log = Logger(printer: SimplePrinter());
  
  late final FirebaseFirestore firestoreInstance;
  late final CollectionReference<Map<String, dynamic>> roomsCollection;
  
  FirebaseRoomRepository() {
    firestoreInstance = FirebaseFirestore.instance;
    roomsCollection = firestoreInstance.collection("rooms");
  }

  /// Fetches a single [Room] stream.
  Stream<Room> getRoomStream(String roomId) {
    log.i("getRoomStream() invoked...");

    return roomsCollection
      .doc(roomId)
      .snapshots()
      .map((DocumentSnapshot<Map<String, dynamic>> snapshot) =>
        Room.fromDocument(snapshot.data()!)
      );
  }

  /// Fetches [Message]s [List] stream.
  Stream<List<Message>> getMessagesStream(String roomId) {
    log.i("getMessagesStream() invoked...");
    
    return roomsCollection
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
     DocumentReference roomRef = roomsCollection.doc();

    await roomRef.set(
      isPrivate
        ? Room.emptyPrivateChatRoom.copyWith(id: roomRef.id).toDocument()
        : Room.emptyGroupChatRoom.copyWith(id: roomRef.id).toDocument()
    );

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
