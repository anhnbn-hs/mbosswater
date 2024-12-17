import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class GuaranteeBeforeWithoutQrCodeStep extends StatefulWidget {
  final VoidCallback onNextStep;
  final TextEditingController reasonController;

  const GuaranteeBeforeWithoutQrCodeStep({
    super.key,
    required this.onNextStep,
    required this.reasonController,
  });

  @override
  State<GuaranteeBeforeWithoutQrCodeStep> createState() => GuaranteeBeforeWithoutQrCodeStepState();
}

class GuaranteeBeforeWithoutQrCodeStepState extends State<GuaranteeBeforeWithoutQrCodeStep>
    with AutomaticKeepAliveClientMixin {
  late UserInfoBloc userInfoBloc;
  late FetchCustomerBloc fetchCustomerBloc;
  Customer? customer;

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    fetchCustomerBloc = BlocProvider.of<FetchCustomerBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return BlocBuilder(
      bloc: fetchCustomerBloc,
      builder: (context, state) {
        if (state is FetchCustomerLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 70),
          );
        }
        if (state is FetchCustomerSuccess) {
          customer = state.customer;
          return SingleChildScrollView(
            child: Column(
              children: [
                buildBoxField(
                  label: "Khách hàng",
                  value: state.customer.fullName ?? "",
                ),
                const SizedBox(height: 20),
                buildBoxField(
                  label: "Số điện thoại",
                  value: state.customer.phoneNumber ?? "",
                ),
                const SizedBox(height: 20),
                buildBoxField(
                  label: "Sản phẩm",
                  value: "widget.product.name!",
                ),
                const SizedBox(height: 20),
                buildBoxField(
                  label: "Kỹ thuật viên phụ trách",
                  value: userInfoBloc.user!.fullName!,
                ),
                const SizedBox(height: 20),
                buildBoxField(
                  label: "Thời gian",
                  value: DateFormat("dd/MM/yyyy").format(now),
                ),
                const SizedBox(height: 20),
                buildBoxFieldAreaGuarantee(
                  label: "Nguyên nhân bảo hành",
                  hint: "Mô tả tình trạng sản phẩm",
                  controller: widget.reasonController,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  onTap: () {
                    if (widget.reasonController.text.trim().isEmpty) {
                      DialogUtils.showWarningDialog(
                        context: context,
                        title: "Hãy nhập nguyên nhân bảo hành tiếp tục!",
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Column buildBoxField({
    required String label,
    required String value,
    // required TextEditingController controller,
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
              onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
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

  @override
  bool get wantKeepAlive => true;
}
