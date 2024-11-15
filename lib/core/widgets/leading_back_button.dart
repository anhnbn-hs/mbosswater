import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class LeadingBackButton extends StatelessWidget {
  const LeadingBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: ImageHelper.loadAssetImage(
        AppAssets.icArrowLeft,
        fit: BoxFit.fill,
        width: 26,
        height: 24,
        tintColor: Colors.black87,
      ),
    );
  }
}