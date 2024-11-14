// Step 2: Customer Information
import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';

class CustomerInfoStep extends StatelessWidget {
  final VoidCallback onNextStep, onPreStep;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  CustomerInfoStep({
    super.key,
    required this.onPreStep,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextFieldItem(
              label: "Họ và tên khách hàng",
              hint: "Nhập họ tên khách hàng",
              controller: nameController,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Text(
                    "Địa chỉ",
                    style: AppStyle.boxFieldLabel,
                  ),
                  Text(
                    " * ",
                    style: AppStyle.boxFieldLabel.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 38,
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
                          "Tỉnh/TP", // Default item, not selectable
                          "TP.Ha Noi",
                          "TP. HCM",
                        ].map((value) {
                          return PopupMenuItem<String>(
                            value: value,
                            height: 30,
                            enabled: value != "Tỉnh/TP",
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
                              "Tỉnh/TP", // Show default text
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
                    height: 38,
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
                          "Tỉnh/TP", // Default item, not selectable
                          "TP.Ha Noi",
                          "TP. HCM",
                        ].map((value) {
                          return PopupMenuItem<String>(
                            value: value,
                            height: 30,
                            enabled: value != "Quận/Huyện",
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
                              "Quận/Huyện", // Show default text
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 38,
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
                          "Tỉnh/TP", // Default item, not selectable
                          "TP.Ha Noi",
                          "TP. HCM",
                        ].map((value) {
                          return PopupMenuItem<String>(
                            value: value,
                            height: 30,
                            enabled: value != "Phường/Xã",
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
                              "Phường/Xã", // Show default text
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
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xffBDBDBD),
                      ),
                    ),
                    child: TextField(
                      controller: addressController,
                      style: AppStyle.boxField.copyWith(),
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Địa chỉ chi tiết",
                        hintStyle: AppStyle.boxField,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      cursorColor: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            buildTextFieldItem(
              label: "Số điện thoại",
              hint: "SĐT",
              controller: phoneController,
            ),
            const SizedBox(height: 12),
            buildTextFieldItem(
              label: "Email",
              hint: "Email",
              controller: emailController,
              isRequired: false,
            ),
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
                if(checkInput()){
                  onNextStep();
                }
              },
              textButton: "TIẾP TỤC",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldItem({
    required String label,
    required String hint,
    bool isRequired = true,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Text(
                label,
                style: AppStyle.boxFieldLabel,
              ),
              isRequired
                  ? Text(
                      " * ",
                      style: AppStyle.boxFieldLabel.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffBDBDBD))),
          child: TextField(
            controller: controller,
            style: AppStyle.boxField.copyWith(),
            decoration: InputDecoration(
                border: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                hintText: hint,
                hintStyle: AppStyle.boxField,
                contentPadding: const EdgeInsets.symmetric(vertical: 12)),
            cursorColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  bool checkInput() {
    String name = nameController.text;
    String phone = phoneController.text;
    // Some fields

    if (name.isEmpty && phone.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
