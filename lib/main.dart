import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_theme.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/change_password_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/go_router.dart';

import 'features/login/presentation/bloc/login_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  initServiceLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<VerifyEmailBloc>()),
        BlocProvider(create: (_) => sl<VerifyOtpBloc>()),
        BlocProvider(create: (_) => sl<ChangePasswordBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MBossWater',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
