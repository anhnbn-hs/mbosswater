import 'package:flutter/material.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Danh Sách Khách Hàng",
                    style: TextStyle(
                      color: Color(0xff820a1a),
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 38,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xffEEEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'BeVietNam',
                      color: Color(0xff3C3C43),
                    ),
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Tìm kiếm khách hàng',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'BeVietNam',
                          color: Colors.grey.shade500,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey.shade400,
            height: 40,
            thickness: .2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  const Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      "KH: 0333333333",
                      style: TextStyle(
                        color: Color(0xff820a1a),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildCustomerInfoItem(
                    label: "Họ và tên",
                    value: " Nguyễn Thị A",
                  ),
                  buildCustomerInfoItem(
                    label: "Địa chỉ",
                    value: "Ba Vì, Hà Nội",
                  ),
                  buildCustomerInfoItem(
                    label: "Đơn hàng",
                    value: "3 sản phẩm",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

  }

  Widget buildCustomerInfoItem({required String label, required String value}) {
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
