import 'package:chab/firebase_options.dart';
import 'package:chab/my_app.dart';
import 'package:chab/util/shared_preferences_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await SharedPreferencesUtil.init();

  runApp(
    RepositoryProvider(
      create: (context) => FirebaseUserRepository(),
      child: const MyApp()
    )
  );
}
