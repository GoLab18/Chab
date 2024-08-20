import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/src/models/usr.dart';
import 'entities/usr_entity.dart';
import 'user_repo.dart';
import 'util/result.dart';

class FirebaseUserRepository implements UserRepository {
  late final FirebaseAuth _firebaseAuth;
  final CollectionReference<Map<String, dynamic>> usersCollection = FirebaseFirestore.instance.collection("users");

  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map<User?>((User? fbUser) {
      return fbUser;
    });
  }

  /// Connects to firebase authentication and signs up
  /// Returns appropriate [Result] type on success or failure
  @override
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
  @override
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
        case 'user-not-found':
          return 'Account not found corresponding to the email';
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

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  @override
  Future<void> setUserData(Usr user) async {
    try {
      await usersCollection.doc(user.id).set(user.toEntity().toDocument());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  @override
  Future<Usr> getUsr(String usrId) async {
    try {
      return await usersCollection.doc(usrId).get().then((value) =>
        Usr.fromEntity(UsrEntity.fromDocument(value.data()!))
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}