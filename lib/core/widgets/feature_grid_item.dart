import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class FeatureGridItem extends StatelessWidget {
  final String title, subtitle, assetIcon;
  final VoidCallback onTap;

  const FeatureGridItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xcaf4f4f4),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE5E5E5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageHelper.loadAssetImage(
                  assetIcon,
                  width: 26,
                  height: 26,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppStyle.titleItem.copyWith(
                          color: const Color(0xffAD1227),
                        ),
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppStyle.subTitleItem,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
