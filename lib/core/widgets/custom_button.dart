import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String textButton;
  BorderRadius? borderRadius;
  bool? secondaryButton;

  CustomButton({
    super.key,
    required this.onTap,
    required this.textButton,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.secondaryButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: secondaryButton == true ? const Color(0xffC2C2C2) : AppColors.primaryColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              textButton,
              style: const TextStyle(
                fontFamily: 'BeVietnam',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
