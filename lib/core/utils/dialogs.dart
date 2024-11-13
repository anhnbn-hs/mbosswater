import 'dart:ui';

import 'package:flutter/material.dart';

enum MessageType { success, error, warning }

class DialogUtils {
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
    required String textCancelButton,
    required String textAcceptButton,
    required VoidCallback acceptPressed,
    bool reverseButton = false,
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 110,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  reverseButton
                      ? Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: acceptPressed,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xff603F26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textAcceptButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xffEEEEEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textCancelButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xffEEEEEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textCancelButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: acceptPressed,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xff603F26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textAcceptButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
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
