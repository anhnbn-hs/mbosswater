import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class TextFieldLabelItem extends StatelessWidget {
  TextFieldLabelItem({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isEnable = true,
    this.isRequired = true,
    this.focusNode,
    this.inputType = TextInputType.text,
    this.formatter,
  });

  final String label, hint;
  bool isRequired, isEnable;
  FocusNode? focusNode;
  TextInputType inputType;
  final TextEditingController controller;
  List<TextInputFormatter>? formatter;

  @override
  Widget build(BuildContext context) {
    return buildTextFieldItem(
      label: label,
      hint: hint,
      controller: controller,
      isRequired: isRequired,
      isEnable: isEnable,
      focusNode: focusNode,
      inputType: inputType,
      formatter: formatter,
    );
  }

  Widget buildTextFieldItem({
    required String label,
    required String hint,
    bool isRequired = true,
    bool isEnable = true,
    FocusNode? focusNode,
    TextInputType inputType = TextInputType.text,
    required TextEditingController controller,
    List<TextInputFormatter>? formatter,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: label != ""
              ? Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.boxFieldLabel.copyWith(fontSize: 15),
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
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: !isEnable ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffBDBDBD),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            focusNode: focusNode,
            enabled: isEnable,
            inputFormatters: formatter,
            style: AppStyle.boxField.copyWith(
              color: Colors.black87,
              fontSize: 15,
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: hint,
              hintStyle: AppStyle.boxField.copyWith(
                color: const Color(0xff828282),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              isCollapsed: true,
            ),
            cursorColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}
