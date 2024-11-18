// Step 1: Product Information
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class ProductInfoStep extends StatefulWidget {
  final Product? product;
  final VoidCallback onNextStep;

  const ProductInfoStep({
    super.key,
    this.product,
    required this.onNextStep,
  });

  @override
  State<ProductInfoStep> createState() => ProductInfoStepState();
}

class ProductInfoStepState extends State<ProductInfoStep>
    with AutomaticKeepAliveClientMixin {
  late ProductBloc productBloc;
  late UserInfoBloc userInfoBloc;

  void performAction() {
    widget.onNextStep();
  }

  @override
  void initState() {
    super.initState();
    productBloc = BlocProvider.of<ProductBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    int? guaranteeDuration = widget.product?.duration;
    DateTime endDate = calculateEndDateFromDuration(guaranteeDuration!);
    String endDateFormatted = DateFormat("dd/MM/yyyy").format(endDate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBoxItem(
              label: "Tên sản phẩm",
              fieldValue: widget.product?.name ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Dòng sản phẩm",
              fieldValue: widget.product?.category ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày bắt đầu bảo hành",
              fieldValue: DateFormat("dd/MM/yyyy").format(now),
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Thời gian bảo hành",
              fieldValue: widget.product?.guaranteeDuration ?? "Không xác định",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày kết thúc bảo hành",
              fieldValue: endDateFormatted,
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Đại lý",
              fieldValue: "Đại lý MbossWater - Lạng Sơn",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Nhân viên bán hàng",
              fieldValue: userInfoBloc.user!.fullName!,
            ),
            const SizedBox(height: 40),
            CustomButton(
              onTap: () {
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

  Widget buildBoxItem({
    required String label,
    required String fieldValue,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: AppStyle.boxFieldLabel,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            fieldValue,
            style: AppStyle.boxField,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
