// Step 1: Product Information
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';

class ProductInfoStep extends StatelessWidget {
  final Product? product;
  final VoidCallback onNextStep;

  const ProductInfoStep({
    super.key,
    this.product,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBoxItem(
              label: "Tên sản phẩm",
              fieldValue: product?.name ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Dòng sản phẩm",
              fieldValue: product?.category ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày bắt đầu bảo hành",
              fieldValue: DateFormat("dd/MM/yyyy").format(now),
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Thời gian bảo hành",
              fieldValue: "12 tháng",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày kết thúc bảo hành",
              fieldValue: DateFormat("dd/MM/yyyy")
                  .format(now.add(const Duration(days: 365))),
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Đại lý",
              fieldValue: "Đại lý MbossWater - Lạng Sơn",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Nhân viên bán hàng",
              fieldValue: "Nguyễn Ngọc Nam",
            ),
            const SizedBox(height: 40),
            CustomButton(
              onTap: onNextStep,
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
}
