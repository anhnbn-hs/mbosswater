import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_agency_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossEditAgencyPage extends StatefulWidget {
  const MbossEditAgencyPage({super.key, required this.agency});

  final Agency agency;

  @override
  State<MbossEditAgencyPage> createState() => _MbossEditAgencyPageState();
}

class _MbossEditAgencyPageState extends State<MbossEditAgencyPage> {
  // Text editing controller
  late final TextEditingController agencyNameController;
  late final TextEditingController agencyAddressController;
  TextEditingController agencyBossNameController = TextEditingController();
  TextEditingController agencyBossPhoneController = TextEditingController();
  TextEditingController agencyBossEmailController = TextEditingController();

  // FocusNode
  final agencyNameFocusNode = FocusNode();
  final agencyAddressFocusNode = FocusNode();
  final agencyBossNameFocusNode = FocusNode();
  final agencyBossPhoneFocusNode = FocusNode();

  // Bloc
  late FetchAgenciesBloc fetchAgenciesBloc;
  late UpdateAgencyBloc updateAgencyBloc;
  late DeleteAgencyBloc deleteAgencyBloc;

  // Variable store Agency and User (Agency Admin)
  late Agency agency;
  UserModel? agencyAdmin;

  @override
  void initState() {
    super.initState();
    agency = widget.agency;
    fetchAgenciesBloc = BlocProvider.of<FetchAgenciesBloc>(context);
    updateAgencyBloc = BlocProvider.of<UpdateAgencyBloc>(context);
    deleteAgencyBloc = BlocProvider.of<DeleteAgencyBloc>(context);
    // Init data
    agencyNameController = TextEditingController(text: widget.agency.name);
    agencyAddressController =
        TextEditingController(text: widget.agency.address);
  }

  @override
  void dispose() {
    super.dispose();
    agencyNameController.dispose();
    agencyAddressController.dispose();
    agencyBossNameController.dispose();
    agencyBossPhoneController.dispose();
    agencyBossEmailController.dispose();
    agencyNameFocusNode.dispose();
    agencyAddressFocusNode.dispose();
    agencyBossNameFocusNode.dispose();
    agencyBossPhoneFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const LeadingBackButton(),
        centerTitle: true,
        title: Text(
          maxLines: 2,
          widget.agency.name,
          style: AppStyle.appBarTitle.copyWith(
            color: AppColors.appBarTitleColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Thông tin đại lý",
                  style: AppStyle.titleItem.copyWith(
                    color: const Color(0xff820a1a),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFieldLabelItem(
                label: "Mã đại lý",
                hint: "Mã đại lý",
                isRequired: false,
                isEnable: false,
                controller: TextEditingController(text: agency.code),
              ),
              const SizedBox(height: 12),
              TextFieldLabelItem(
                label: "Tên đại lý",
                hint: "Tên đại lý",
                isRequired: true,
                controller: agencyNameController,
                focusNode: agencyNameFocusNode,
              ),
              const SizedBox(height: 12),
              TextFieldLabelItem(
                label: "Địa chỉ",
                hint: "Địa chỉ",
                isRequired: true,
                controller: agencyAddressController,
                focusNode: agencyAddressFocusNode,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Thông tin chủ đại lý",
                  style: AppStyle.titleItem.copyWith(
                    color: const Color(0xff820a1a),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: fetchAgenciesBloc.fetchAdminOfAgency(widget.agency.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(AppAssets.aLoading, height: 50),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  if (snapshot.data != null &&
                      snapshot.connectionState == ConnectionState.done) {
                    agencyAdmin = snapshot.data;
                    agencyBossNameController.text = agencyAdmin?.fullName ?? "";
                    agencyBossPhoneController.text =
                        agencyAdmin?.phoneNumber ?? "";
                    agencyBossEmailController.text = agencyAdmin?.email ?? "";
                    return Column(
                      children: [
                        TextFieldLabelItem(
                          label: "Họ và tên",
                          hint: "Họ và tên",
                          isRequired: true,
                          controller: agencyBossNameController,
                          focusNode: agencyBossNameFocusNode,
                          formatter: [
                            FilteringTextInputFormatter.deny(RegExp(r'\d'))
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Số điện thoại",
                          hint: "Số điện thoại",
                          isRequired: true,
                          controller: agencyBossPhoneController,
                          focusNode: agencyBossPhoneFocusNode,
                          formatter: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Email",
                          hint: "Email",
                          isRequired: false,
                          controller: agencyBossEmailController,
                        ),
                      ],
                    );
                  } else {
                    return const Text("Không có chủ đại lý cho đại lý này.");
                  }
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: handleDeleteStaff,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: const Color(0xffC2C2C2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            "XÓA",
                            style: TextStyle(
                              fontFamily: "BeVietnam",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: InkWell(
                      onTap: () async => handleUpdateAgency(),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            "CẬP NHẬT",
                            style: TextStyle(
                              fontFamily: "BeVietnam",
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 30),
              BlocListener<UpdateAgencyBloc, bool>(
                listener: (context, state) async {
                  if (updateAgencyBloc.isLoading == false && state == true) {
                    DialogUtils.hide(context);
                    fetchAgenciesBloc.fetchAllAgencies();
                  }
                },
                child: const SizedBox.shrink(),
              ),
              BlocListener<DeleteAgencyBloc, bool>(
                listener: (context, state) async {
                  if (deleteAgencyBloc.isLoading == false && state == true) {
                    DialogUtils.hide(context);
                    DialogUtils.hide(context);
                    await fetchAgenciesBloc.fetchAllAgencies();
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleUpdateAgency() async {
    String agencyName = agencyNameController.text.trim();
    String agencyAddress = agencyAddressController.text.trim();

    String bossName = agencyBossNameController.text.trim();
    String bossPhone = agencyBossPhoneController.text.trim();
    String bossEmail = agencyBossEmailController.text.trim();

    if (agencyName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập tên đại lý",
        onClickOutSide: () {},
      );
      agencyNameFocusNode.requestFocus();
      return;
    }

    if (agencyAddress.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ đại lý",
        onClickOutSide: () {},
      );
      agencyAddressFocusNode.requestFocus();
      return;
    }

    if (bossName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập họ tên chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossNameFocusNode.requestFocus();
      return;
    }

    if (bossPhone.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossPhoneFocusNode.requestFocus();
      return;
    }

    // Assign value
    agency.name = agencyName;
    agency.address = agencyAddress;

    agencyAdmin?.fullName = bossName;
    agencyAdmin?.phoneNumber = bossPhone;
    agencyAdmin?.email = bossEmail;

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận cập nhật thông tin đại lý này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);

        // Check phoneNumber of agency boss
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: bossPhone)
            .where(FieldPath.documentId, isNotEqualTo: agencyAdmin?.id)
            .limit(1)
            .get();

        bool isPhoneExisted = userDoc.docs.isNotEmpty;

        if (!isPhoneExisted) {
          await updateAgencyBloc.updateAgency(
            agency: agency,
            user: agencyAdmin!,
          );
        } else {
          DialogUtils.hide(context);
          agencyBossPhoneFocusNode.requestFocus();
          DialogUtils.showWarningDialog(
            context: context,
            title: "Số điện thoại đã được đăng ký!",
            onClickOutSide: () {},
          );
        }
      },
    );
  }

  handleDeleteStaff() async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn xoá đại lý này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        await deleteAgencyBloc.deleteAgency(
          agency: agency,
          agencyAdmin: agencyAdmin!,
        );
      },
    );
  }
}

class BoxFieldItem extends StatefulWidget {
  final String hintValue;
  final bool isRequired;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatter;

  const BoxFieldItem({
    Key? key,
    required this.hintValue,
    this.isRequired = false,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.formatter = const [],
  }) : super(key: key);

  @override
  _BoxFieldItemState createState() => _BoxFieldItemState();
}

class _BoxFieldItemState extends State<BoxFieldItem> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffD9D9D9)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.formatter,
            style: AppStyle.bodyText.copyWith(
              color: const Color(0xff303030),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: widget.isRequired ? "" : widget.hintValue,
              hintStyle: widget.isRequired
                  ? null
                  : AppStyle.bodyText.copyWith(
                      color: const Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          if (widget.isRequired && widget.controller.text.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RichText(
                    text: TextSpan(
                      text: widget.hintValue,
                      style: AppStyle.bodyText.copyWith(
                        color: const Color(0xffB3B3B3),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text: ' * ',
                          style: TextStyle(
                            fontFamily: "BeVietnam",
                            color: Color(0xff820a1a),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
