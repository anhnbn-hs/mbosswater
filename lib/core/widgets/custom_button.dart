import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String textButton;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.textButton,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
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
