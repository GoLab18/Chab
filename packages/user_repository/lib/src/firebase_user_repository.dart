import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'models/models.dart';
import 'util/result.dart';
import 'util/typedefs.dart';

class FirebaseUserRepository {
  final Logger log = Logger(printer: SimplePrinter());

  final Dio esClient;

  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference<Map<String, dynamic>> usersCollection;
  late final CollectionReference<Map<String, dynamic>> roomsCollection;
  late final CollectionReference<Map<String, dynamic>> friendInvitesCollection;

  FirebaseUserRepository({
    required this.esClient,
    FirebaseAuth? firebaseAuth
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

    usersCollection = firestoreInstance.collection("users");
    roomsCollection = firestoreInstance.collection("rooms");
    friendInvitesCollection = firestoreInstance.collection("friend_invites");
  }

  Stream<User?> get user {
    try {
      return _firebaseAuth.authStateChanges().map<User?>((User? fbUser) {
        log.i("Authentication state changed");
        return fbUser;
      });
    } on FirebaseAuthException catch (e) {
      log.e("User auth stream fetching failed, error: $e");
      throw Exception(e);
    }
  }

  /// Connects to firebase authentication and signs up
  /// Returns appropriate [Result] type on success or failure
  Future<Result<Usr, String>> signUp(Usr user, String password) async {
    log.i("signUp() invoked...");

    try {
      UserCredential newUser = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password
      );

      user = user.copyWith(
        id: newUser.user!.uid
      );

      log.i("Sign up successful");
      return Result.success<Usr, String>(user);
    } on FirebaseAuthException catch (e) {
      log.e("Sign up failed, error: $e");

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
    log.i("signIn() invoked...");

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      log.i("Sign in with email: $email successful");
      return null;
    } on FirebaseAuthException catch (e) {
      log.e("Sign in failed with email: $email, error: $e");

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
    log.i("signOut() invoked...");

    try {
      await _firebaseAuth.signOut();

      log.i("Sign out successful");
    } on FirebaseAuthException catch (e) {
      log.e("Sign out failed, error: $e");
      throw Exception(e.code);
    }
  }

  /// Sends a reset password email to a specified [email].
  Future<void> resetPassword(String email) async {
    log.i("resetPassword() invoked...");

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email
      );
      
      log.i("Password reset for email: \"$email\" successful");
    } on FirebaseAuthException catch (e) {
      log.e("Password reset failed for email: \"$email\", error: $e");
      throw Exception(e.code);
    }
  }

  Future<Usr> getUsr(String usrId) async {
    log.i("getUsr() invoked...");

    try {
      var usr = await usersCollection.doc(usrId).get().then((value) =>
        Usr.fromDocument(value.data()!)
      );

      log.i("Getting user with id: \"$usrId\" successful");
      return usr;
    } catch (e) {
      log.e("Getting user with id: \"$usrId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Adds a new user to the database.
  Future<void> addUser(Usr user) async {
    log.i("addUser() invoked...");

    try {
      await usersCollection.doc(user.id).set(user.toDocument());
      
      await esClient.put(
        "/users/_doc/${user.id}",
        data: user.toEsObject()
      );
      
      log.i("Adding user: $user successful");
    } catch (e) {
      log.e("Adding user: $user failed: $e");
      throw Exception(e);
    }
  }

  /// Sets user fields like email, username etc.
  Future<void> setUserData(Usr user) async {
    log.i("setUserData() invoked...");

    try {
      await usersCollection.doc(user.id).update({
        "name": user.name,
        "email": user.email,
        "bio": user.bio
      });

      await esClient.post(
        "/users/_update/${user.id}",
        data: {
          "doc": user.toEsObject(),
          "doc_as_upsert": true
        }
      );

      log.i("Setting user data with id: \"${user.id}\" successful");
    } catch (e) {
      log.e("Setting user data with id: \"${user.id}\" failed: $e");
      throw Exception(e);
    }
  }

  /// Function for strictly adding and updating user profile pictures.
  /// The picture is stored inside firebase storage and it's download URL is stored inside firebase firestore.
  Future<String> uploadPicture(String userId, String imagePath) async {
    log.i("uploadPicture() invoked...");

    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        "Users/$userId/ProfilePictures/${userId}_pic"
      );

      File imageFile = File(imagePath);

      await firebaseStorageRef.putFile(imageFile);

      String picUrl = await firebaseStorageRef.getDownloadURL();

      await usersCollection.doc(userId).update({
        "picture": picUrl
      });

      await esClient.post(
        "/users/_update/$userId",
        data: {
          "doc": {
            "picture": picUrl
          }
        }
      );

      log.i("Uploading profile picture for user with id: \"$userId\" successful");
      return picUrl;
    } catch (e) {
      log.e("Uploading profile picture for user with id: \"$userId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Fetches private chat room friend's User instance.
  Future<Stream<Usr>> getPrivateChatRoomFriend(String roomId, String currentUserId) async {
    log.i("getPrivateChatRoomFriend() invoked...");

    try {
      QuerySnapshot<Map<String, dynamic>> membersSnapshot = await roomsCollection
        .doc(roomId)
        .collection("members")
        .get();

      String friendId = membersSnapshot
        .docs
        .map((doc) => doc.id)
        .toList()
        .firstWhere((memberId) => memberId != currentUserId);

      var r = usersCollection
        .doc(friendId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) =>
          Usr.fromDocument(snapshot.data()!)
        );

      log.i("Fetching private chat room friend with id: \"$roomId\" successful");

      return r;
    } catch (e) {
      log.e("Fetching private chat room friend with id: \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Fetches group chat room members Stream.
  /// Updates happen incrementally based on changes in group chat room members.
  Future<Stream<Map<String, Usr>>> getGroupChatRoomMembersStream(String roomId) async {
    log.i("getGroupChatRoomMembersStream() invoked...");

    try {
      var r = roomsCollection
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

      log.i("Fetching group chat room members with id: \"$roomId\" successful");

      return r;
    } catch (e) {
      log.e("Fetching group chat room members with id: \"$roomId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Fetches users that sent the current user an invite.
  /// Returns a [Stream] with a [List] that holds an [Invite] with the corresponding [Usr].
  /// [List] is ordered by [Timestamp] ascending and holds only invites with [InviteStatus.pending].
  Future<Stream<List<(Usr, Invite)>>> getUserFriendInvites(String userId) async {
    log.i("getUserFriendInvites() invoked...");

    try {
      log.i("Fetching received invites data...");

      QuerySnapshot<Map<String, dynamic>> invitesSnapshot = await friendInvitesCollection
        .where("toUser", isEqualTo: userId)
        .where("status", isEqualTo: InviteStatus.pending.index)
        .orderBy("timestamp", descending: true)
        .get();

      List<Invite> invites = invitesSnapshot.docs.map((doc) => Invite.fromDocument(doc.data())).toList();
      List<String> sendersIds = invites.map((invite) => invite.fromUser).toList();

      // Incase no invites
      if (sendersIds.isEmpty) {
        return Stream.value([]);
      }

      return usersCollection
        .where(FieldPath.documentId, whereIn: sendersIds)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> sendersSnapshot) {
          log.i("Mapping received invites' users data...");

          Map<String, dynamic> docsMap = {for (var doc in sendersSnapshot.docs) doc.id: doc};

          return invites
            .map((invite) {
              return (
                Usr.fromDocument(docsMap[invite.fromUser].data()),
                invite
            );
            })
            .toList();
        });
    } catch (e) {
      log.e("Fetching received invites error: $e");
      throw Exception(e);
    }
  }

  /// Fetches users that have been invited by the current user.
  /// Returns a [Stream] with a [List] that holds an [Invite] with the corresponding [Usr].
  /// [List] is ordered by [Timestamp] ascending.
  Stream<List<(Usr, Invite)>> getCurrentUsersIssuedInvites(String userId) {
    log.i("getCurrentUsersIssuedInvites() invoked...");

    try {
      // Manages the combined output
      StreamController<List<(Usr, Invite)>> controller = StreamController.broadcast();

      // Combined streams
      StreamSubscription? invitesSub;
      StreamSubscription? receiversSub;

      // Listening to the outer invites stream
      invitesSub = friendInvitesCollection
        .where("fromUser", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> invitesSnapshot) {
          log.i("Handling issued invites data...");

          List<Invite> invites = invitesSnapshot.docs
            .map((doc) => Invite.fromDocument(doc.data()))
            .toList();

          List<String> receiversIds = invites.map((invite) => invite.toUser).toList();

          // If no receivers, emitting an empty list
          if (receiversIds.isEmpty) {
            controller.add(<(Usr, Invite)>[]);
            return;
          }

          // Fetching users based on receiversIds
          receiversSub = usersCollection
            .where(FieldPath.documentId, whereIn: receiversIds)
            .snapshots()
            .listen((QuerySnapshot<Map<String, dynamic>> receiversSnapshot) {
              log.i("Handling issued invite users data...");
              
              Map<String, Usr> usersMap = {
                for (var doc in receiversSnapshot.docs)
                  doc.id: Usr.fromDocument(doc.data())
              };
              
              // Combining user and invite data
              List<(Usr, Invite)> finalList = invites.map((invite) {
                Usr? user = usersMap[invite.toUser];
                
                return user != null ? (user, invite) : null;
              }).where((element) => element != null).cast<(Usr, Invite)>().toList();

              log.i("Emitting issued invites data");

              // Emitting the results
              controller.add(finalList);
            });
        });

      // Cleaning up after cancel
      controller.onCancel = () {
        receiversSub?.cancel();
        invitesSub?.cancel();
        controller.close();

        log.w("Received invites controller cleaned up");
      };

      return controller.stream;
    } catch (e) {
      log.e("Fetching issued invites error: $e");
      throw Exception(e);
    }
  }

  /// Updates the status [int] of a specified invite with an id [String].
  Future<void> updateInviteStatus(String inviteId, InviteStatus status) async {
    log.i("updateInviteStatus() invoked...");

    try {
      await friendInvitesCollection
        .doc(inviteId)
        .update({
          "status": status.index
        });

      await esClient.post(
        "/friend_invites/_update/$inviteId",
        data: {
          "doc": {
            "status": status.index
          }
        }
      );

      log.i("Invite status update with id: \"$inviteId\" successful");
    } catch (e) {
      log.e("Invite status update with id: \"$inviteId\" failed: $e");
      throw Exception(e);
    }
  }

  /// Delete an invite with a specified [String] id.
  Future<void> deleteInvite(String inviteId) async {
    log.i("deleteInvite() invoked...");

    try {
      await friendInvitesCollection
        .doc(inviteId)
        .delete();

      await esClient.delete("/friend_invites/_doc/$inviteId");

      log.i("Invite deletion with id: \"$inviteId\" successful");
    } catch (e) {
      log.e("Invite deletion with id: \"$inviteId\" failed: $e");
      throw Exception(e);
    }
  }
}
