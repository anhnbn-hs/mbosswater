import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';

class GuaranteeAfterStep extends StatefulWidget {
  final Function(XFile?) onConfirm;
  final TextEditingController stateAfterController;

  const GuaranteeAfterStep(
      {super.key, required this.onConfirm, required this.stateAfterController});

  @override
  State<GuaranteeAfterStep> createState() => _GuaranteeAfterStepState();
}

class _GuaranteeAfterStepState extends State<GuaranteeAfterStep>
    with AutomaticKeepAliveClientMixin {
  ValueNotifier<XFile?> pickedImageNotifier = ValueNotifier(null);

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: source);

    if (image == null) return;

    pickedImageNotifier.value = image;

    // Upload image logic
    // await uploadImage(image);
  }

  @override
  void dispose() {
    pickedImageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        buildBoxFieldAreaGuarantee(
          label: "Sau khi bảo hành",
          hint: "Mô tả tình trạng sản phẩm sau khi bảo hành ",
          controller: widget.stateAfterController,
        ),
        ValueListenableBuilder(
          valueListenable: pickedImageNotifier,
          builder: (context, value, child) {
            if (value != null) {
              return Container(
                width: 200,
                height: 200,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.file(
                  File(value.path),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () async => await pickImage(ImageSource.camera),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xffD9D9D9),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryColor,
                ),
                Text(
                  "Chụp ảnh",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "BeVietnam",
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        CustomButton(
          onTap: () {
            if (widget.stateAfterController.text.trim().isEmpty) {
              DialogUtils.showWarningDialog(
                context: context,
                title: "Hãy nhập tình trạng sau bảo hành!",
                onClickOutSide: () {},
              );
              return;
            }
            if (pickedImageNotifier.value == null) {
              DialogUtils.showWarningDialog(
                context: context,
                title: "Hãy chụp ảnh tình trạng sau bảo hành để tiếp tục!",
                onClickOutSide: () {},
              );
              return;
            }
            widget.onConfirm(pickedImageNotifier.value);
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
                        fontFamily: "BeVietnam",
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
            onTapOutside: (event) =>
                FocusScope.of(context).requestFocus(FocusNode()),
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
              color: Colors.black87,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
