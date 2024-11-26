import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';

class GuaranteeAfterStep extends StatefulWidget {
  const GuaranteeAfterStep({super.key});

  @override
  State<GuaranteeAfterStep> createState() => _GuaranteeAfterStepState();
}

class _GuaranteeAfterStepState extends State<GuaranteeAfterStep> {
  final TextEditingController stateAfterController = TextEditingController();

  @override
  void dispose() {
    stateAfterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBoxFieldAreaGuarantee(
          label: "Sau khi bảo hành",
          hint: "Mô tả tình trạng sản phẩm sau khi bảo hành ",
          controller: stateAfterController,
        ),
        const Spacer(),
        CustomButton(
          onTap: () {
            DialogUtils.showConfirmationDialog(
              context: context,
              title: "",
              labelTitle: "Bạn chắc chắn xác nhận\nthông tin trên ?",
              textCancelButton: "Huỷ",
              textAcceptButton: "Xác nhận",
              cancelPressed: () => Navigator.pop(context),
              acceptPressed: () {},
            );
          },
          textButton: "XÁC NHẬN",
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Column buildBoxFieldAreaGuarantee({
    required String label,
    required String hint,
    required TextEditingController controller,
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
                      style: AppStyle.boxFieldLabel.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      " * ",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffD9D9D9),
            ),
          ),
          child: TextField(
              maxLines: 6,
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: "Mô tả tình trạng sản phẩm",
                hintStyle: AppStyle.boxField.copyWith(
                  fontSize: 15,
                  color: const Color(0xffB3B3B3),
                ),
              ),
              cursorHeight: 20,
              style: AppStyle.boxField.copyWith(
                fontSize: 15,
                color: Colors.grey,
                height: 1,
              )),
        ),
      ],
    );
  }
}