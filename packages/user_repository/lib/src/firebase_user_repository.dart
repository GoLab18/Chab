import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'models/models.dart';
import 'util/result.dart';
import 'util/typedefs.dart';

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
  Future<Stream<Map<String, Usr>>> getGroupChatRoomMembersStream(String roomId) async {
    try {
      return roomsCollection
        .doc(roomId)
        .collection("members")
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.docs.map((doc) => doc.id).toList()
        )
        .asyncExpand((List<String> roomMembersIds) =>
          roomMembersIds.isEmpty  
            ? Stream.value(<String, Usr>{})
            : usersCollection
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
  /// Returns a [Stream] with a [List] that holds an [Invite] with the corresponding [Usr].
  /// [List] is ordered by [Timestamp] ascending and holds only invites with [InviteStatus.pending].
  Future<Stream<List<(Usr, Invite)>>> getUserFriendInvites(String userId) async {
    try {
      return friendInvitesCollection
        .where("toUser", isEqualTo: userId)
        .where("status", isEqualTo: InviteStatus.pending.index)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> invitesSnapshot) =>
          invitesSnapshot.docs.map((doc) => Invite.fromDocument(doc.data())).toList()
        )
        .asyncExpand((List<Invite> invites) {
          List<String> sendersIds = [];

          for (Invite invite in invites) {
            sendersIds.add(invite.fromUser);
          }

          if (sendersIds.isEmpty) {
            return Stream.value(<(Usr, Invite)>[]);
          }

          return usersCollection
            .where(FieldPath.documentId, whereIn: sendersIds)
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> sendersSnapshot) {
              Map<String, dynamic> docsMap = {for (var doc in sendersSnapshot.docs) doc.id: doc};

              List<(Usr, Invite)> finalList = [];

              for (Invite invite in invites) {
                finalList.add(
                  (
                    Usr.fromDocument(docsMap[invite.fromUser].data()),
                    invite
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
  /// Returns a [Stream] with a [List] that holds an [Invite] with the corresponding [Usr].
  /// [List] is ordered by [Timestamp] ascending.
  Future<Stream<List<(Usr, Invite)>>> getCurrentUsersIssuedInvites(String userId) async {
    try {
      return friendInvitesCollection
        .where("fromUser", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> invitesSnapshot) =>
          invitesSnapshot.docs.map((doc) => Invite.fromDocument(doc.data())).toList()
        )
        .asyncExpand((List<Invite> invites) {
          List<String> receiversIds = [];

          for (Invite invite in invites) {
            receiversIds.add(invite.toUser);
          }
          
          if (receiversIds.isEmpty) {
            return Stream.value(<(Usr, Invite)>[]);
          }

          return usersCollection
            .where(FieldPath.documentId, whereIn: receiversIds)
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> receiversSnapshot) {
              Map<String, dynamic> docsMap = {for (var doc in receiversSnapshot.docs) doc.id: doc};

              List<(Usr, Invite)> finalList = [];

              for (Invite invite in invites) {
                finalList.add(
                  (
                    Usr.fromDocument(docsMap[invite.toUser].data()),
                    invite
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

  /// Updates the status [int] of a specified invite with an id [String].
  Future<void> updateInviteStatus(String inviteId, InviteStatus status) async {
    try {
      return await friendInvitesCollection
        .doc(inviteId)
        .update({
          "status": status.index
        });
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Delete an invite with a specified [String] id.
  Future<void> deleteInvite(String inviteId) async {
    try {
      return await friendInvitesCollection
        .doc(inviteId)
        .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
