import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String textButton;
  double? height;
  BorderRadius? borderRadius;

  CustomButton({
    super.key,
    required this.onTap,
    required this.textButton,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
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
