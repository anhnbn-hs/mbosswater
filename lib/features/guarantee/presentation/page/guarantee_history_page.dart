import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_state.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';

class GuaranteeHistoryPage extends StatefulWidget {
  final Guarantee guarantee;
  final Customer customer;

  const GuaranteeHistoryPage({
    super.key,
    required this.guarantee,
    required this.customer,
  });

  @override
  State<GuaranteeHistoryPage> createState() => _GuaranteeHistoryPageState();
}

class _GuaranteeHistoryPageState extends State<GuaranteeHistoryPage> {
  late AgencyBloc agencyBloc;
  late GuaranteeHistoryBloc guaranteeHistoryBloc;

  @override
  void initState() {
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
    guaranteeHistoryBloc = BlocProvider.of<GuaranteeHistoryBloc>(context);
    // Fetch data
    agencyBloc.fetchAgency(widget.customer.agency ?? "");
    guaranteeHistoryBloc.add(FetchListGuaranteeHistory(widget.guarantee.id));
    super.initState();
  }

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
      body: SingleChildScrollView(
        child: Padding(
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
                label: "Model máy",
                value: widget.guarantee.product.model ?? "",
              ),
              buildGuaranteeInfoItem(
                label: "Seri màng lọc Dow",
                value: widget.guarantee.product.seriDow ?? "SRDxxx",
              ),
              BlocBuilder(
                bloc: agencyBloc,
                builder: (context, state) {
                  if (state is AgencyLoaded) {
                    return buildGuaranteeInfoItem(
                      label: "Đại lý",
                      value: state.agency.name,
                    );
                  }
                  return buildGuaranteeInfoItem(
                    label: "Đại lý",
                    value: "",
                  );
                },
              ),
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
              BlocBuilder(
                bloc: guaranteeHistoryBloc,
                builder: (context, state) {
                  if (state is GuaranteeHistoryLoading) {
                    return Center(
                      child: Lottie.asset(AppAssets.aLoading, height: 50),
                    );
                  }
                  if (state is GuaranteeHistoryListLoaded) {
                    if (state.guaranteeHistories.isEmpty) {
                      return const Center(
                        child: Text(
                          "Không có lịch sử bảo hành",
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.guaranteeHistories.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                          thickness: .3,
                          height: 16,
                        );
                      },
                      itemBuilder: (context, index) {
                        final dateFormat = DateFormat("dd/MM/yyyy").format(
                            state.guaranteeHistories[index].date!.toDate());
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              if (state.guaranteeHistories.length > 1)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Lần ${state.guaranteeHistories.length - index}",
                                    style: AppStyle.boxFieldLabel.copyWith(
                                      color: const Color(0xff820a1a),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              buildGuaranteeInfoItem(
                                label: "Kỹ thuật viên",
                                value: state.guaranteeHistories[index]
                                        .technicalName ??
                                    "",
                              ),
                              buildGuaranteeInfoItem(
                                label: "Ngày bảo hành",
                                value: dateFormat,
                              ),
                              buildHistoryItem(
                                label: "Nguyên nhân bảo hành",
                                value: state.guaranteeHistories[index]
                                        .beforeStatus ??
                                    "",
                              ),
                              const SizedBox(height: 16),
                              buildHistoryItem(
                                label: "Sau khi bảo hành",
                                value: state.guaranteeHistories[index]
                                        .afterStatus ??
                                    "",
                              )
                            ],
                          ),
                        );
                      },
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
          const SizedBox(width: 50),
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                value,
                maxLines: 2,
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
