import 'package:chat_application/data/repositries/chat_repository.dart';
import 'package:chat_application/data/services/service_locator.dart';
import 'package:chat_application/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_application/logic/cubits/auth/auth_state.dart';
import 'package:chat_application/logic/observer/app_lifecycle_observer.dart';
import 'package:chat_application/prasantation/home/home_screen.dart';
import 'package:chat_application/prasantation/screens/auth/login_screen.dart';
import 'package:chat_application/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async{
  await setupServiceLocator();
   runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late AppLifeCycleObserver _lifeCycleObserver;
  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if(state.status == AuthStatus.authanticate && state.user != null){
        _lifeCycleObserver = AppLifeCycleObserver(userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
      }
      WidgetsBinding.instance.addObserver(_lifeCycleObserver);
    },);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      title: 'messenger app',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthCubit,AuthState>(
        bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if(state.status == AuthStatus.initial){
              return Scaffold(body: Center(child: CircularProgressIndicator(),),);
            }
            if(state.status == AuthStatus.authanticate){
              return const HomeScreen();
            }
            return const LoginScreen();
          },),
    );
  }
}
