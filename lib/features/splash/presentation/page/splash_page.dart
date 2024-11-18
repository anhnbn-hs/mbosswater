import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_event.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late UserInfoBloc userInfoBloc;

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    navigate();
  }

  Future<void> navigate() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Fetch user data
      userInfoBloc.add(FetchUserInfo(currentUser.uid));
    } else {
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => context.go("/login"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: userInfoBloc,
      listener: (context, state) {
        if (state is UserInfoLoaded) {
          context.go("/home");
        }
        if (state is UserInfoError) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageHelper.loadAssetImage(AppAssets.imgLogo),
              const SizedBox(height: 10),
              Text(
                "MbossWater",
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
