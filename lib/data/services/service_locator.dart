import 'package:chat_application/data/repositries/auth_repository.dart';
import 'package:chat_application/data/repositries/chat_repository.dart';
import 'package:chat_application/data/repositries/contact_repository.dart';
import 'package:chat_application/data/repositries/notification_repository.dart';
import 'package:chat_application/data/services/notifications.dart';
import 'package:chat_application/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_application/logic/cubits/chat/chat_cubit.dart';
import 'package:chat_application/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../../firebase_options.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getIt.registerLazySingleton(() => AppRouter(),);
  getIt.registerLazySingleton(() => AuthRepository(),);
  getIt.registerLazySingleton(() => ContactRepository(),);
  getIt.registerLazySingleton(() => ChatRepository(notificationRepository:NotificationRepository()),);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance,);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance,);
  getIt.registerLazySingleton(() => AuthCubit(authRepository: AuthRepository()),);
  getIt.registerFactory(() => ChatCubit(chatRepository: ChatRepository(notificationRepository: NotificationRepository()), currentUserId: getIt<FirebaseAuth>().currentUser!.uid),);
  getIt.registerLazySingleton(() => NotificationService());
  await getIt<NotificationService>().initialize();
}