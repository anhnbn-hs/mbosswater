import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/presentation/step_request_screen/confirm_phone_number_step.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class GuaranteeBeforeWithoutQRCodeStep extends StatefulWidget {
  final VoidCallback onNextStep;
  final GlobalKey<ConfirmPhoneNumberStepState> confirmStepKey;
  final TextEditingController reasonController;

  const GuaranteeBeforeWithoutQRCodeStep({
    super.key,
    required this.onNextStep,
    required this.reasonController,
    required this.confirmStepKey,
  });

  @override
  State<GuaranteeBeforeWithoutQRCodeStep> createState() =>
      GuaranteeBeforeWithoutQRCodeStepState();
}

class GuaranteeBeforeWithoutQRCodeStepState
    extends State<GuaranteeBeforeWithoutQRCodeStep>
    with AutomaticKeepAliveClientMixin {
  late UserInfoBloc userInfoBloc;
  Customer? customer;
  Guarantee? guarantee;
  ValueNotifier<XFile?> pickedImageNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  void dispose() {
    pickedImageNotifier.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: source);

    if (image == null) return;

    pickedImageNotifier.value = image;

    // Upload image logic
    // await uploadImage(image);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.confirmStepKey.currentState != null){
      customer = widget.confirmStepKey.currentState?.customerSearched.value;
      guarantee = widget.confirmStepKey.currentState?.guaranteeSelected.value;
    }
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildBoxFieldCannotEdit(
              label: "Khách hàng",
              value: customer?.fullName ?? "",
            ),
            const SizedBox(height: 20),
            buildBoxFieldCannotEdit(
              label: "Số điện thoại",
              value: customer?.phoneNumber ?? "",
            ),
            const SizedBox(height: 20),
            buildBoxFieldCannotEdit(
              label: "Sản phẩm",
              value: guarantee?.product.name ?? "",
            ),
            const SizedBox(height: 20),
            buildBoxFieldCannotEdit(
              label: "Model máy",
              value: guarantee?.product.model ?? "",
            ),
            const SizedBox(height: 20),
            buildBoxFieldCannotEdit(
              label: "Kỹ thuật viên phụ trách",
              value: userInfoBloc.user!.fullName!,
            ),
            const SizedBox(height: 20),
            buildBoxFieldCannotEdit(
              label: "Thời gian",
              value: DateFormat("dd/MM/yyyy").format(now),
            ),
            const SizedBox(height: 20),
            buildBoxFieldAreaGuarantee(
              label: "Nguyên nhân bảo hành",
              hint: "Mô tả tình trạng sản phẩm",
              controller: widget.reasonController,
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: pickedImageNotifier,
              builder: (context, value, child) {
                if (value != null) {
                  return Container(
                    width: 200,
                    height: 200,
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
            const SizedBox(height: 40),
            CustomButton(
              onTap: () {
                if (widget.reasonController.text.trim().isEmpty) {
                  DialogUtils.showWarningDialog(
                    context: context,
                    title: "Hãy nhập nguyên nhân bảo hành để tiếp tục!",
                    onClickOutSide: () {},
                  );
                  return;
                }

                if (pickedImageNotifier.value == null) {
                  DialogUtils.showWarningDialog(
                    context: context,
                    title: "Hãy chụp ảnh tình trạng trước bảo hành để tiếp tục!",
                    onClickOutSide: () {},
                  );
                  return;
                }
                widget.onNextStep();
              },
              textButton: "TIẾP TỤC",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Column buildBoxFieldCannotEdit({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Align(
          alignment: FractionalOffset.centerLeft,
          child: Text(
            label,
            style: AppStyle.boxFieldLabel.copyWith(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffD9D9D9),
            ),
          ),
          child: Text(
            value,
            maxLines: 2,
            style: AppStyle.boxField.copyWith(
              fontSize: 15,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ),
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
              )),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
