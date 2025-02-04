import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class CustomerCardItem extends StatelessWidget {
  final Customer customer;

  const CustomerCardItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          "/customer-detail",
          extra: customer,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xffDADADA),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "KH: ${customer.phoneNumber}",
                style: const TextStyle(
                  fontFamily: "BeVietNam",
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            buildCustomerInfoItem(
              label: "Họ và tên",
              value: "${customer.fullName}",
            ),
            buildCustomerInfoItem(
              label: "Địa chỉ",
              value: customer.address!.displayAddress(),
            ),
            buildCustomerInfoItem(
              label: "Số sản phẩm",
              value: customer.totalProduct.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: "BeVietnam",
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
                maxLines: 2,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: "BeVietnam",
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
