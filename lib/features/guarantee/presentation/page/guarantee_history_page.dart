import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class GuaranteeHistoryPage extends StatefulWidget {
  final Guarantee guarantee;

  const GuaranteeHistoryPage({super.key, required this.guarantee});

  @override
  State<GuaranteeHistoryPage> createState() => _GuaranteeHistoryPageState();
}

class _GuaranteeHistoryPageState extends State<GuaranteeHistoryPage> {
  @override
  Widget build(BuildContext context) {
    bool expired = isExpired(widget.guarantee.endDate);
    final startDate = widget.guarantee.createdAt.toDate();
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    // end date
    final endDateFormatted =
        DateFormat("dd/MM/yyyy").format(widget.guarantee.endDate);
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Text(
          "#${widget.guarantee.id}",
          style: AppStyle.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Sản phẩm",
                style: TextStyle(
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildGuaranteeInfoItem(
              label: "Tên sản phẩm",
              value: widget.guarantee.product.name!,
            ),
            buildGuaranteeInfoItem(
              label: "Mã sản phẩm",
              value: widget.guarantee.product.id,
            ),
            buildGuaranteeInfoItem(label: "Đại lý", value: "Đại lý Lạng Sơn"),
            const SizedBox(height: 16),
            const Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Thông tin bảo hành",
                style: TextStyle(
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tình trạng",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 36),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: CircleAvatar(
                          backgroundColor: expired
                              ? AppColors.primaryColor
                              : const Color(0xff00B81C),
                          radius: 4,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        expired ? "Hết hạn" : "Còn hạn",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            buildGuaranteeInfoItem(
              label: "Ngày bắt đầu",
              value: startDateFormatted,
            ),
            buildGuaranteeInfoItem(
              label: "Ngày kết thúc",
              value: endDateFormatted,
            ),
            buildGuaranteeInfoItem(
              label: "Thời gian bảo hành",
              value: "${widget.guarantee.product.duration} tháng",
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Lịch sử bảo hành",
                style: TextStyle(
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildGuaranteeInfoItem(
              label: "Kỹ thuật viên",
              value: "Nguyễn Văn A",
            ),
            buildGuaranteeInfoItem(
              label: "Ngày bảo hành",
              value: "20/11/2024",
            ),
            buildHistoryItem(
                label: "Nguyên nhân bảo hành", value: "Nước bị rò rỉ, ..."),
            const SizedBox(height: 16),
            buildHistoryItem(
              label: "Sau khi bảo hành",
              value: "Đã khắc phục lỗi, máy chạy bình thường",
            )
          ],
        ),
      ),
    );
  }

  Widget buildHistoryItem({required String label, required String value}) {
    return Column(
      children: [
        Align(
          alignment: FractionalOffset.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 36,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffBDBDBD), width: .5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: FractionalOffset.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildGuaranteeInfoItem(
      {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 36),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
