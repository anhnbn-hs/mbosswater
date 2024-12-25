import 'package:flutter/material.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class ImagePreviewPopup extends StatelessWidget {
  final String imageUrl;
  final double maxWidth;
  final double maxHeight;

  const ImagePreviewPopup({
    Key? key,
    required this.imageUrl,
    this.maxWidth = 300,
    this.maxHeight = 400,
  }) : super(key: key);

  void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) => this,
      transitionBuilder: (context, animation1, animation2, child) {
        return FadeTransition(
          opacity: animation1,
          child: ScaleTransition(
            scale: animation1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: maxWidth,
        height: maxHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Image with zoom
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(0),
                child: ImageHelper.loadNetworkImage(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Close button
            Positioned(
              right: -12,
              top: -12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}