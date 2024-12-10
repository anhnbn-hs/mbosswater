import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class LeadingBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const LeadingBackButton({
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ?? () => context.pop(),
      icon: ImageHelper.loadAssetImage(
        AppAssets.icArrowLeft,
        tintColor: const Color(0xff111827),
      ),
    );
  }
}