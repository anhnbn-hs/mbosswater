import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const CustomFloatingActionButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ImageHelper.loadAssetImage(
                  AppAssets.icQrCode,
                  height: 24,
                  width: 24,
                  fit: BoxFit.fill,
                ),
                const SizedBox(width: 12),
                const Text(
                  "KÍCH HOẠT BẢO HÀNH",
                  style: TextStyle(
                    fontFamily: 'BeVietnam',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}