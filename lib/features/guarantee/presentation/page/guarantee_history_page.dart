import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_state.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/image_preview_popup.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

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
  late ValueNotifier<String> modelNotifier;
  late UserInfoBloc userInfoBloc;

  @override
  void initState() {
    modelNotifier = ValueNotifier(widget.guarantee.product.model ?? "");
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
    guaranteeHistoryBloc = BlocProvider.of<GuaranteeHistoryBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    // Fetch data
    agencyBloc.fetchAgency(widget.customer.agency ?? "");
    guaranteeHistoryBloc.add(FetchListGuaranteeHistory(widget.guarantee.id));
    super.initState();
  }

  Future<String?> getUserFullNameByTechnicalID(String technicalID) async {
    try {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(technicalID)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.get('fullName')?.toString();
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool expired = isExpired(widget.guarantee.endDate);
    final startDate = widget.guarantee.createdAt.toDate();
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    int remainingMonth = getRemainingMonths(widget.guarantee.endDate);
    // end date
    final endDateFormatted =
        DateFormat("dd/MM/yyyy").format(widget.guarantee.endDate);
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        scrolledUnderElevation: 0,
        title: Text(
          "#${widget.guarantee.id.toUpperCase()}",
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
                    fontFamily: "BeVietnam",
                    color: Color(0xff820a1a),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Tên sản phẩm",
                    style: TextStyle(
                      fontFamily: "BeVietnam",
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        widget.guarantee.product.name ?? "",
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
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN) {
                    await showBottomSheetEditModel();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: modelNotifier,
                      builder: (context, value, child) => Expanded(
                        child: buildGuaranteeInfoItem(
                          label: "Model máy",
                          value: modelNotifier.value,
                        ),
                      ),
                    ),
                    if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 3),
                      child: Icon(Icons.edit_outlined, size: 20),
                    )
                  ],
                ),
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
                    value: "Khách lẻ",
                  );
                },
              ),
              FutureBuilder<String?>(
                future:
                    getUserFullNameByTechnicalID(widget.guarantee.technicalID),
                builder: (context, snapshot) => buildGuaranteeInfoItem(
                  label: "Nhân viên kỹ thuật",
                  value: snapshot.data ?? "",
                ),
              ),
              if (widget.guarantee.technicalSupportID != null)
                FutureBuilder<String?>(
                  future: getUserFullNameByTechnicalID(
                      widget.guarantee.technicalSupportID!),
                  builder: (context, snapshot) => buildGuaranteeInfoItem(
                    label: "Nhân viên hỗ trợ",
                    value: snapshot.data ?? "",
                  ),
                ),
              if (widget.guarantee.product.note != "")
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Text(
                        "Ghi chú",
                        style: TextStyle(
                          fontFamily: "BeVietnam",
                          color: Color(0xff820a1a),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6F6F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          widget.guarantee.product.note ?? "",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              const Align(
                alignment: FractionalOffset.centerLeft,
                child: Text(
                  "Thông tin bảo hành",
                  style: TextStyle(
                    fontFamily: "BeVietnam",
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
                        fontFamily: "BeVietnam",
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
                        const SizedBox(width: 6),
                        Text(
                          expired
                              ? "Hết hạn"
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
                      child: Lottie.asset(AppAssets.aLoading, height: 60),
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
                                imageUrl: state.guaranteeHistories[index]
                                        .imageBefore ??
                                    "",
                              ),
                              const SizedBox(height: 16),
                              buildHistoryItem(
                                label: "Sau khi bảo hành",
                                value: state.guaranteeHistories[index]
                                        .afterStatus ??
                                    "",
                                imageUrl: state
                                        .guaranteeHistories[index].imageAfter ??
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

  Widget buildHistoryItem({
    required String label,
    required String value,
    required String? imageUrl,
  }) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xffF6F6F6),
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
            ),
            const SizedBox(height: 12),
            if (imageUrl != null && imageUrl != "")
              GestureDetector(
                onTap: () {
                  final size = MediaQuery.of(context).size;
                  ImagePreviewPopup(
                    imageUrl: imageUrl,
                    maxWidth: size.width * 0.85,
                    maxHeight: size.height * 0.6,
                  ).show(context);
                },
                child: ImageHelper.loadNetworkImage(
                  height: 90,
                  width: 140,
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "BeVietnam",
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                value,
                maxLines: 2,
                textAlign: TextAlign.end,
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

  final modelController = TextEditingController();
  final modelFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    modelController.dispose();
    modelFocusNode.dispose();
    modelNotifier.dispose();
  }

  showBottomSheetEditModel() async {
    final updatedModel = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        modelController.text = modelNotifier.value;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cập nhật Model máy',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "BeVietnam",
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: modelController,
                  focusNode: modelFocusNode,
                  onTapOutside: (event) =>
                      FocusScope.of(context).requestFocus(FocusNode()),
                  decoration: InputDecoration(
                    labelText: 'Model máy',
                    labelStyle: const TextStyle(color: Colors.black54),
                    hintText: 'Nhập model máy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(Icons.phone_android),
                  ),
                  cursorColor: Colors.grey,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BeVietnam",
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, modelController.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontFamily: "BeVietnam",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (updatedModel != null &&
        updatedModel.trim() != widget.guarantee.product.model) {
      DialogUtils.showLoadingDialog(context);
      await FirebaseFirestore.instance
          .collection("guarantees")
          .doc(widget.guarantee.id)
          .update({"product.model": updatedModel});
      modelNotifier.value = updatedModel;
      widget.guarantee.product.model = updatedModel;
      DialogUtils.hide(context);
    }
    modelController.text = "";
  }
}
