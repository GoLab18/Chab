import 'package:firebase_auth/firebase_auth.dart';

import 'models/models.dart';
import 'util/result.dart';


abstract class UserRepository {

  Stream<User?> get user;
  
  Future<Result<Usr, String>> signUp(Usr user, String password);

  Future<String?> signIn(String email, String password);

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> setUserData(Usr user);

  Future<Usr> getUsr(String usrId);
}