import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer? customer;

  const CustomerDetailPage({super.key, this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late CustomerGuaranteeBloc customerGuaranteeBloc;

  @override
  void initState() {
    super.initState();
    customerGuaranteeBloc = BlocProvider.of<CustomerGuaranteeBloc>(context);
    customerGuaranteeBloc.add(FetchCustomerGuarantees(widget.customer!.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Text(
          "Lịch Sử Mua Hàng",
          style: AppStyle.appBarTitle.copyWith(
            color: AppColors.appBarTitleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Khách hàng",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              buildCustomerInfoItem(
                label: "Họ tên",
                value: widget.customer?.fullName ?? "---",
              ),
              buildCustomerInfoItem(
                label: "Số điện thoại",
                value: widget.customer?.phoneNumber ?? "---",
              ),
              buildCustomerInfoItem(
                label: "Địa chỉ",
                maxLine: 2,
                value: "${widget.customer?.address!.displayAddress()}",
              ),
              buildCustomerInfoItem(
                label: "Email",
                value: widget.customer?.email != ""
                    ? widget.customer?.email ?? "---"
                    : "",
              ),
              const SizedBox(height: 40),
              BlocBuilder(
                bloc: customerGuaranteeBloc,
                builder: (context, state) {
                  if (state is CustomerGuaranteeLoading) {
                    return Center(
                      child: Lottie.asset(AppAssets.aLoading, height: 70),
                    );
                  }
                  if (state is CustomerGuaranteeLoaded) {
                    final guarantees = state.guarantees;
                    return ListView.builder(
                      itemCount: guarantees.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildGuaranteeItem(guarantees[index]),
                        );
                      },
                    );
                  }
                  if (state is CustomerGuaranteeError) {
                    return const Center(
                      child: Text("Error"),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGuaranteeItem(Guarantee guarantee) {
    final startDate = guarantee.createdAt.toDate();
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    bool expired = isExpired(guarantee.endDate);
    int remainingMonth = getRemainingMonths(guarantee.endDate);
    return GestureDetector(
      onTap: () {
        context.push(
          '/guarantee-history',
          extra: [guarantee, widget.customer],
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
                "#${guarantee.id.toUpperCase()}",
                style: const TextStyle(
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            buildCustomerInfoItem(
              label: "Sản phẩm",
              value:
                  guarantee.product.name ?? "Máy Lọc Nước Tạo Kiềm MBossWater",
            ),
            buildCustomerInfoItem(
              label: "Model máy",
              value: guarantee.product.model ?? "",
            ),
            buildCustomerInfoItem(
              label: "Seri màng lọc",
              value: guarantee.product.seriDow ?? "",
            ),
            buildCustomerInfoItem(
              label: "Ngày kích hoạt",
              value: startDateFormatted,
            ),
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
                        expired
                            ? "Hết hạn bảo hành"
                            : "Còn $remainingMonth tháng bảo hành",
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
          ],
        ),
      ),
    );
  }

  Widget buildCustomerInfoItem(
      {required String label, required String value, int maxLine = 1}) {
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
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: maxLine,
                textAlign: TextAlign.end,
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
