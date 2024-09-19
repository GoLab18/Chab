import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/src/models/usr.dart';
import 'util/result.dart';

class FirebaseUserRepository {
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference<Map<String, dynamic>> usersCollection;
  late final CollectionReference<Map<String, dynamic>> roomsCollection;
  late final CollectionReference<Map<String, dynamic>> friendInvitesCollection;

  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

    usersCollection = firestoreInstance.collection("users");
    roomsCollection = firestoreInstance.collection("rooms");
    friendInvitesCollection = firestoreInstance.collection("friend_invites");
  }

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map<User?>((User? fbUser) {
      return fbUser;
    });
  }

  /// Connects to firebase authentication and signs up
  /// Returns appropriate [Result] type on success or failure
  Future<Result<Usr, String>> signUp(Usr user, String password) async {
    try {
      UserCredential newUser = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password
      );

      user = user.copyWith(
        id: newUser.user!.uid
      );

      return Result.success<Usr, String>(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return Result.failure<Usr, String>('Email address already in use');
        case 'invalid-email':
          return Result.failure<Usr, String>('Invalid email');
        case 'too-many-requests':
          return Result.failure<Usr, String>('Too many attempts, try again later');
        case 'network-request-failed':
          return Result.failure<Usr, String>('Network request failed');
        default:
          return Result.failure<Usr, String>('Sign in failed, please try again');
      }
    }
  }

  /// Connects to firebase authentication and signs in
  /// Returns null if sign in was successful
  /// Returns appropriate errors if sign in was unsuccessful
  Future<String?> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email';
        case 'wrong-password':
          return 'Wrong password';
        case 'invalid-credential':
          return 'Wrong password';
        case 'user-not-found':
          return 'Account corresponding to this email not found';
        case 'too-many-requests':
          return 'Too many attempts, try again later';
        case 'user-disabled':
          return 'Account corresponding to the email is disabled';
        case 'network-request-failed':
          return 'Network request failed';
        default:
          return 'Sign in failed, please try again';
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Sends a reset password email to a specified [email].
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<Usr> getUsr(String usrId) async {
    try {
      return await usersCollection.doc(usrId).get().then((value) =>
        Usr.fromDocument(value.data()!)
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Adds a new user to the database.
  Future<void> addUser(Usr user) async {
    try {
      await usersCollection.doc(user.id).set(user.toDocument());
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Sets user fields like email, username etc.
  Future<void> setUserData(Usr user) async {
    try {
      await usersCollection.doc(user.id).update({
        "name": user.name,
        "email": user.email,
        "bio": user.bio
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Function for strictly adding and updating user profile pictures
  Future<String> uploadPicture(String userId, String pictureStorageUrl) async {
    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        "$userId/ProfilePictures/${userId}_pic"
      );

      File imageFile = File(pictureStorageUrl);

      await firebaseStorageRef.putFile(imageFile);

      String picUrl = await firebaseStorageRef.getDownloadURL();

      await usersCollection.doc(userId).update({
        "picture": picUrl
      });

      return picUrl;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Fetches private chat friend id.
  Future<String> getPrivateChatRoomFriendId(String roomId, String currentUserId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> membersSnapshot = await roomsCollection
        .doc(roomId)
        .collection("members")
        .get();

      return membersSnapshot
        .docs
        .map((doc) => doc.id)
        .toList()
        .firstWhere((memberId) => memberId != currentUserId);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Fetches group chat room members Stream.
  /// Updates happen incrementally based on changes in group chat room members.
  Stream<Map<String, Usr>> getGroupChatRoomMembersStream(String roomId) {
    try {
      return roomsCollection
        .doc(roomId)
        .collection("members")
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.docs.map((doc) => doc.id).toList()
        )
        .asyncExpand((List<String> roomMembersIds) =>
          usersCollection
            .where(FieldPath.documentId, whereIn: roomMembersIds)
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> userSnapshot) {
              Map<String, Usr> usersMap = {};

              for (var doc in userSnapshot.docs) {
                Usr user = Usr.fromDocument(doc.data());
                usersMap[user.id] = user;
              }
              
              return usersMap;
            })
        )
        .asBroadcastStream();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Fetches users that sent the current user an invite.
  /// Returns a [Stream] with a [Map] that holds a [Record] with a [Usr] and an invite [DateTime].
  /// [Map] fields can be accessed through senders' Ids. // TODO change
  Future<Stream<List<(Usr, DateTime)>>> getUserFriendInvites(String userId) async {
    try {
      return friendInvitesCollection
        .where("toUser", isEqualTo: userId)
        .orderBy("timestamp")
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> invitesSnapshot) =>
          invitesSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();

            return (
              data["fromUser"] as String,
              (data["timestamp"] as Timestamp).toDate()
            );
          })
          .toList()
        )
        .asyncExpand((List<(String, DateTime)> records) {
          List<String> sendersIds = [];
          List<DateTime> dateTimes = [];

          for ((String, DateTime) record in records) {
            sendersIds.add(record.$1);
            dateTimes.add(record.$2);
          }

          if (sendersIds.isEmpty) {
            return Stream.value(<(Usr, DateTime)>[]);
          }

          return usersCollection
            .where(FieldPath.documentId, whereIn: sendersIds)
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> sendersSnapshot) {
              var docsList = sendersSnapshot.docs;
              List<(Usr, DateTime)> finalList = [];

              for (int i = 0; i < docsList.length; i++) {
                finalList.add(
                  (
                    Usr.fromDocument(docsList[i].data()),
                    dateTimes[i]
                  )
                );
              }

              return finalList;
            });
        })
        .asBroadcastStream();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Fetches users that have been invited by the current user.
  /// Returns a [Stream] with a [Map] that holds a [Record] with a [Usr] and an invite [DateTime].
  /// [Map] fields can be accessed through receivers' Ids. // TODO change
  Future<Stream<List<(Usr, DateTime)>>> getCurrentUsersIssuedInvites(String userId) async {
    try {
      return friendInvitesCollection
        .where("fromUser", isEqualTo: userId)
        .orderBy("timestamp") 
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> invitesSnapshot) =>
          invitesSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();

            return (
              data["toUser"] as String,
              (data["timestamp"] as Timestamp).toDate()
            );
          })
          .toList()
        )
        .asyncExpand((List<(String, DateTime)> records) {
          List<String> receiversIds = [];
          List<DateTime> dateTimes = [];

          for ((String, DateTime) record in records) {
            receiversIds.add(record.$1);
            dateTimes.add(record.$2);
          }
          
          if (receiversIds.isEmpty) {
            return Stream.value(<(Usr, DateTime)>[]);
          }

          return usersCollection
            .where(FieldPath.documentId, whereIn: receiversIds)
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> receiversSnapshot) {
              var docsList = receiversSnapshot.docs;
              List<(Usr, DateTime)> finalList = [];

              for (int i = 0; i < docsList.length; i++) {
                finalList.add(
                  (
                    Usr.fromDocument(docsList[i].data()),
                    dateTimes[i]
                  )
                );
              }

              return finalList;
            });
        })
        .asBroadcastStream();
    } catch (e) {
      throw Exception(e);
    }
  }
}}