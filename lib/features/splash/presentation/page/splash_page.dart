import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  Future<void> navigate() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await Future.delayed(
        const Duration(seconds: 1),
        () => context.go("/home"),
      );
    } else {
      await Future.delayed(
        const Duration(seconds: 1),
        () => context.go("/login"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
