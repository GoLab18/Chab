import 'package:chab/firebase_options.dart';
import 'package:chab/my_app.dart';
import 'package:chab/util/orientation_util.dart';
import 'package:chab/util/shared_preferences_util.dart';
import 'package:es_client_repository/es_client_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await SharedPreferencesUtil.init();

  await lockPhoneOrientationVertical();

  final esClient = await EsConfig.setup(dotenv.env);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => FirebaseUserRepository(esClient: esClient)
        ),
        RepositoryProvider(
          create: (context) => FirebaseRoomRepository(esClient: esClient)
        )
      ],
      child: const MyApp()
    )
  );
}
