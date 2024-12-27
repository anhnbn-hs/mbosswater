import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

class ResendButton extends StatefulWidget {
  final Function() onResend;

  ResendButton({required this.onResend});

  @override
  _ResendButtonState createState() => _ResendButtonState();
}

class _ResendButtonState extends State<ResendButton> {
  int _start = 60;
  Timer? _timer;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonEnabled = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isButtonEnabled ? widget.onResend : null,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Gửi lại",
              style: TextStyle(
                fontFamily: "BeVietnam",
                color: AppColors.textErrorColor,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: _isButtonEnabled ? FontWeight.w700 : FontWeight.w300,
              ),
            ),
            if (!_isButtonEnabled) // Hiển thị bộ đếm ngược khi không thể gửi lại
              TextSpan(
                text: ' $_start' 's',
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: AppColors.textErrorColor,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
