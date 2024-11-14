import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

enum MessageType { success, error, warning }

class DialogUtils {
  static Future<void> showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Lottie.asset(
                AppAssets.aLoading,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop(); // Đóng dialog
  }

  static void showMessageDialogAutoClose(BuildContext context, String message) {
    // Show a custom dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Success',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
            ],
          ),
        );
      },
    );
  }

  static void showConfirmationDialog({
    required BuildContext context,
    required Size size,
    required String title,
    String? labelTitle,
    required String textCancelButton,
    required String textAcceptButton,
    required VoidCallback acceptPressed,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, _, __) {
        return Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          alignment: Alignment.center,
          child: Material(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 190,
              width: size.width,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 28,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (labelTitle != null)
                    Text(
                      labelTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "BeVietnam",
                        color: Color(0xff000000),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "BeVietnam",
                        color: Color(0xff1b1e25),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: const Color(0xffC2C2C2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                textCancelButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: InkWell(
                          onTap: acceptPressed,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                textAcceptButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
