// Step 3: Additional Information
import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';

class AdditionalInfoStep extends StatelessWidget {
  AdditionalInfoStep({
    super.key,
    required this.onNextStep,
    required this.onPreStep,
  });

  final VoidCallback onNextStep, onPreStep;

  final TextEditingController phController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Text(
                    "Số lượng thành viên",
                    style: AppStyle.boxFieldLabel,
                  ),
                  // Text(
                  //   " * ",
                  //   style: AppStyle.boxFieldLabel.copyWith(
                  //     color: AppColors.primaryColor,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffBDBDBD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      style: ButtonStyle(
                        textStyle: WidgetStatePropertyAll(AppStyle.boxField),
                      ),
                      onSelected: (value) {
                        // Handle selection, if needed
                      },
                      itemBuilder: (BuildContext context) {
                        // Hide the "Tỉnh/TP" option from being selected
                        return [
                          "Người lớn", // Default item, not selectable
                          "1",
                          "2",
                        ].map((value) {
                          return PopupMenuItem<String>(
                            value: value,
                            height: 30,
                            enabled: value != "Người lớn",
                            // Disable the "Tỉnh/TP" option
                            child: Text(
                              value,
                              style: AppStyle.boxField,
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Người lớn", // Show default text
                              style: AppStyle.boxField,
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffBDBDBD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      style: ButtonStyle(
                        textStyle: WidgetStatePropertyAll(AppStyle.boxField),
                      ),
                      onSelected: (value) {
                        // Handle selection, if needed
                      },
                      itemBuilder: (BuildContext context) {
                        // Hide the "Tỉnh/TP" option from being selected
                        return [
                          "Trẻ em", // Default item, not selectable
                          "1",
                          "2",
                        ].map((value) {
                          return PopupMenuItem<String>(
                            value: value,
                            height: 30,
                            enabled: value != "Trẻ em",
                            // Disable the "Tỉnh/TP" option
                            child: Text(
                              value,
                              style: AppStyle.boxField,
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Trẻ em", // Show default text
                              style: AppStyle.boxField,
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Chất lượng nước",
              style: AppStyle.boxFieldLabel,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            Text(
              "Độ pH",
              style: AppStyle.boxFieldLabel,
            ),
            const SizedBox(height: 12),
            Container(
              height: 38,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffBDBDBD))),
              child: TextField(
                controller: phController,
                style: AppStyle.boxField.copyWith(),
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: AppStyle.boxField,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                cursorColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 50),
            Row(
              children: [
                ImageHelper.loadAssetImage(
                  AppAssets.icArrowLeft,
                  width: 18,
                ),
                TextButton(
                  onPressed: onPreStep,
                  child: const Text(
                    "Quay lại",
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w500,
                      fontFamily: "BeVietnam",
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            CustomButton(
              onTap: () {
                // if(checkInput()){
                  onNextStep();
                // }
              },
              textButton: "XÁC NHẬN BẢO HÀNH",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
