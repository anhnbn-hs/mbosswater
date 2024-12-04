import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/services/notification_service.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class ActiveSuccessPage extends StatefulWidget {
  const ActiveSuccessPage({super.key});

  @override
  _ActiveSuccessPageState createState() => _ActiveSuccessPageState();
}

class _ActiveSuccessPageState extends State<ActiveSuccessPage> {
  late Timer _timer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
        handleNavigate();
      }
    });
  }

  void handleNavigate() {
    context.go("/home");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageHelper.loadAssetImage(AppAssets.imgActiveSuccess),
            const SizedBox(height: 36),
            const Text(
              "Kích Hoạt Thành Công",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 28,
                fontFamily: 'BeVietnam',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Đang chuyển đến trang chủ trong ${_countdown}s",
              style: const TextStyle(
                color: Color(0xffb7b7b7),
                fontSize: 16,
                fontFamily: "BeVietnam",
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Hoặc ấn ",
                  style: TextStyle(
                    color: Color(0xffb7b7b7),
                    fontSize: 16,
                    fontFamily: "BeVietnam",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                InkWell(
                  onTap: () => context.go("/home"),
                  child: const Text(
                    "vào đây",
                    style: TextStyle(
                      color: Color(0xff4741FF),
                      fontSize: 16,
                      fontFamily: "BeVietnam",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
