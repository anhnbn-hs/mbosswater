import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/stats_utils.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_mboss_staff_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossStaffManagement extends StatefulWidget {
  const MbossStaffManagement({super.key});

  @override
  State<MbossStaffManagement> createState() => _MbossStaffManagementState();
}

class _MbossStaffManagementState extends State<MbossStaffManagement> {
  late FetchMbossStaffBloc mbossStaffBloc;
  late CreateMbossStaffBloc createMbossStaffBloc;
  late UpdateMbossStaffBloc updateMbossStaffBloc;
  late DeleteMbossStaffBloc deleteMbossStaffBloc;

  // Controller
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  // Focus node
  final focusNodeName = FocusNode();
  final focusNodePhone = FocusNode();
  final focusNodeAddress = FocusNode();

  ValueNotifier<String?> selectedRole = ValueNotifier(null);
  final List<String> dropdownItems = [
    'Nhân viên kỹ thuật',
    'Nhân viên chăm sóc khách hàng'
  ];

  final List<String> dropdownWorkHistoryItems = [
    'Tháng này',
    '30 ngày gần đây',
    '90 ngày gần đây',
    'Năm nay'
  ];

  ValueNotifier<String?> selectedFilter = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    mbossStaffBloc = BlocProvider.of<FetchMbossStaffBloc>(context);
    createMbossStaffBloc = BlocProvider.of<CreateMbossStaffBloc>(context);
    updateMbossStaffBloc = BlocProvider.of<UpdateMbossStaffBloc>(context);
    deleteMbossStaffBloc = BlocProvider.of<DeleteMbossStaffBloc>(context);
    mbossStaffBloc.fetchMbossStaffs();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    focusNodeName.dispose();
    focusNodePhone.dispose();
    focusNodeAddress.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: const Text(
          "Quản Lý Nhân Viên",
          style: TextStyle(
            fontFamily: 'BeVietnam',
            color: Color(0xff820a1a),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async => await showStaffCreation(),
        child: Container(
          margin: const EdgeInsets.only(right: 5, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 46,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 28),
          Container(
            height: 38,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xffEEEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SearchField(
              onSearch: (value) {
                mbossStaffBloc.searchStaff(value);
              },
            ),
          ),
          Divider(
            color: Colors.grey.shade400,
            height: 40,
            thickness: .2,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: BlocBuilder<FetchMbossStaffBloc, List<UserModel>>(
                bloc: mbossStaffBloc,
                builder: (context, state) {
                  if (mbossStaffBloc.isLoading) {
                    return Center(
                      child: Lottie.asset(AppAssets.aLoading, height: 50),
                    );
                  }
                  if (!mbossStaffBloc.isLoading && state.isNotEmpty) {
                    final listUser = state;
                    int ccCount = listUser
                        .where((user) => user.role == Roles.MBOSS_CUSTOMERCARE)
                        .length;
                    int techCount = listUser
                        .where((user) => user.role == Roles.MBOSS_TECHNICAL)
                        .length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          buildRowInfoItem(
                            label: "Tổng nhân viên",
                            value: listUser.length.toString(),
                          ),
                          buildRowInfoItem(
                            label: "Nhân viên CSKH",
                            value: ccCount.toString(),
                          ),
                          buildRowInfoItem(
                            label: "Nhân viên kỹ thuật",
                            value: techCount.toString(),
                          ),
                          const SizedBox(height: 24),
                          ListView.builder(
                            itemCount: listUser.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: buildStaffItem(listUser[index]),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          // Listener for create
          BlocListener<CreateMbossStaffBloc, bool>(
            listener: (context, state) async {
              if (createMbossStaffBloc.isLoading == false && state == true) {
                DialogUtils.hide(context);
                DialogUtils.hide(context);
                await mbossStaffBloc.fetchMbossStaffs();
              }
            },
            child: const SizedBox.shrink(),
          ),
          // Listener for delete
          BlocListener<DeleteMbossStaffBloc, bool>(
            listener: (context, state) async {
              if (deleteMbossStaffBloc.isLoading == false && state == true) {
                DialogUtils.hide(context);
                DialogUtils.hide(context);
                await mbossStaffBloc.fetchMbossStaffs();
              }
            },
            child: const SizedBox.shrink(),
          ),
          // Listener for update
          BlocListener<UpdateMbossStaffBloc, bool>(
            listener: (context, state) async {
              if (updateMbossStaffBloc.isLoading == false && state == true) {
                DialogUtils.hide(context);
                DialogUtils.hide(context);
                await mbossStaffBloc.fetchMbossStaffs();
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildRowInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyle.titleItem.copyWith(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: AppStyle.titleItem.copyWith(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String getRoleName(String role) {
    if (role == Roles.MBOSS_CUSTOMERCARE) {
      return "Chăm sóc khách hàng";
    }
    if (role == Roles.MBOSS_TECHNICAL) {
      return "Nhân viên kỹ thuật";
    }
    return "";
  }

  Widget buildStaffItem(UserModel user) {
    return GestureDetector(
      onTap: () async {
        await showStaffInformation(
          user: user,
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
            color: user.role == Roles.MBOSS_TECHNICAL
                ? const Color(0xff3F689D)
                : const Color(0xffDADADA),
          ),
        ),
        child: Column(
          children: [
            const Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Mã nhân viên: #111",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            buildRowUserInfoItem(
              label: "Họ và tên",
              value: user.fullName ?? "",
            ),
            buildRowUserInfoItem(
              label: "Chức vụ",
              value: getRoleName(user.role ?? ""),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowUserInfoItem({required String label, required String value}) {
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
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 2,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "BeVietnam",
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

  showStaffInformation({UserModel? user}) async {
    nameController.text = user?.fullName ?? "";
    phoneController.text = user?.phoneNumber ?? "";
    addressController.text = user?.address ?? "";
    emailController.text = user?.email ?? "";

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, _, __) {
        return Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          alignment: Alignment.center,
          child: Material(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Nhân Viên",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildBoxFieldItem(
                            hintValue: "Họ và tên",
                            controller: nameController,
                            focusNode: focusNodeName,
                          ),
                          const SizedBox(height: 26),
                          buildRoleSelection(user?.role),
                          const SizedBox(height: 36),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Liên Hệ",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildBoxFieldItem(
                            hintValue: "Số điện thoại",
                            controller: phoneController,
                            focusNode: focusNodePhone,
                          ),
                          const SizedBox(height: 26),
                          buildBoxFieldItem(
                            hintValue: "Email",
                            controller: emailController,
                          ),
                          const SizedBox(height: 26),
                          buildBoxFieldItem(
                            hintValue: "Địa chỉ",
                            controller: addressController,
                            focusNode: focusNodeAddress,
                          ),
                          const SizedBox(height: 36),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Lịch Sử Công Việc",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilterDropdown(
                              selectedValue: 'Tháng',
                              onChanged: (value) =>
                                  selectedFilter.value = value,
                              options: dropdownWorkHistoryItems,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder(
                            valueListenable: selectedFilter,
                            builder: (context, value, child) {
                              Future<int> future = Future(() => 0);
                              if (value != null) {
                                future = StatsUtils.instance
                                    .getCustomerOfStaffCountWithFilter(
                                  staffID: user?.id ?? "",
                                  filterValue: value,
                                );
                              }
                              if (value == null) {
                                future = StatsUtils.instance
                                    .getCustomerOfStaffCount(user?.id ?? "");
                              }
                              return Column(
                                children: [
                                  FutureBuilder<int>(
                                    future: future,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.connectionState ==
                                              ConnectionState.done) {
                                        return buildRowInfoItem(
                                          label: "Tổng khách hàng",
                                          value:
                                              (snapshot.data ?? 0).toString(),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  if (user?.role == Roles.MBOSS_CUSTOMERCARE)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: buildRowInfoItem(
                                        label: "Nhiệm vụ hoàn thành",
                                        value: "0/30",
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () async => handleDeleteStaff(user),
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
                                          fontWeight: FontWeight.w500,
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
                                  onTap: () async => handleUpdateStaff(user!),
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
                                          fontWeight: FontWeight.w500,
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
                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then(
      (value) {
        selectedFilter.value = null;
      },
    );
  }

  Widget buildRoleSelection(String? role) {
    if (role != null) {
      if (role == Roles.MBOSS_TECHNICAL) {
        selectedRole.value = dropdownItems.first;
      }
      if (role == Roles.MBOSS_CUSTOMERCARE) {
        selectedRole.value = dropdownItems.elementAt(1);
      }
    } else {
      selectedRole.value = null;
    }
    return Container(
      height: 34,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff757575)),
      ),
      child: ValueListenableBuilder(
        valueListenable: selectedRole,
        builder: (context, value, child) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: selectedRole.value,
              hint: const Row(
                children: [
                  Text(
                    "Chức vụ",
                    style: TextStyle(
                      fontFamily: "BeVietnam",
                      color: Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    " * ",
                    style: TextStyle(
                      fontFamily: "BeVietnam",
                      color: Color(0xff900B09),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black87,
              ),
              items: dropdownItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xffB3B3B3),
                      fontFamily: "BeVietnam",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedRole.value = newValue;
              },
            ),
          );
        },
      ),
    );
  }

  showStaffCreation() async {
    nameController.text = "";
    phoneController.text = "";
    addressController.text = "";
    emailController.text = "";

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, _, __) {
        return Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          alignment: Alignment.center,
          child: Material(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thêm Nhân Viên",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildBoxFieldItem(
                            hintValue: "Họ và tên",
                            isRequired: true,
                            controller: nameController,
                            focusNode: focusNodeName,
                          ),
                          const SizedBox(height: 26),
                          buildRoleSelection(null),
                          const SizedBox(height: 36),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Liên Hệ",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildBoxFieldItem(
                            hintValue: "Số điện thoại",
                            isRequired: true,
                            controller: phoneController,
                            focusNode: focusNodePhone,
                          ),
                          const SizedBox(height: 26),
                          buildBoxFieldItem(
                            hintValue: "Email",
                            controller: emailController,
                          ),
                          const SizedBox(height: 26),
                          buildBoxFieldItem(
                            hintValue: "Địa chỉ",
                            controller: addressController,
                          ),
                          const SizedBox(height: 36),
                          CustomButton(
                            onTap: () async => handleCreateStaff(),
                            height: 40,
                            textButton: "TẠO TÀI KHOẢN",
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Container buildBoxFieldItem({
    required String hintValue,
    bool isRequired = false,
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    return Container(
      height: 34,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff757575)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppStyle.bodyText.copyWith(
              color: const Color(0xffB3B3B3),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: isRequired ? "" : hintValue,
              hintStyle: isRequired
                  ? null
                  : AppStyle.bodyText.copyWith(
                      color: const Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
          if (isRequired)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                    text: TextSpan(
                      text: hintValue,
                      style: AppStyle.bodyText.copyWith(
                        color: const Color(0xffB3B3B3),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text: ' * ',
                          style: TextStyle(
                            fontFamily: "BeVietnam",
                            color: Color(0xff900B09),
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

  handleDeleteStaff(UserModel? user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn xoá nhân viên này ?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        await deleteMbossStaffBloc.deleteStaff(user?.id ?? "");
      },
    );
  }

  handleUpdateStaff(UserModel user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn cập nhật nhân viên này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        // Get text field value
        final userUpdate = user;
        userUpdate.fullName = nameController.text.trim();
        userUpdate.address = addressController.text.trim();

        // Get role
        String newRole = "";
        if (selectedRole.value == dropdownItems.first) {
          newRole = Roles.MBOSS_TECHNICAL;
        }
        if (selectedRole.value == dropdownItems.elementAt(1)) {
          newRole = Roles.MBOSS_CUSTOMERCARE;
        }
        userUpdate.role = newRole;
        await updateMbossStaffBloc.updateStaff(userUpdate);
      },
    );
  }

  handleCreateStaff() async {
    String fullName = nameController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String address = addressController.text.trim();
    String email = emailController.text.trim();

    if (fullName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập họ tên nhân viên",
        onClickOutSide: () {},
      );
      focusNodeName.requestFocus();
      return;
    }

    if (selectedRole.value == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn vai trò nhân viên",
        onClickOutSide: () {},
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại",
        onClickOutSide: () {},
      );
      focusNodePhone.requestFocus();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận thêm mới nhân viên: $fullName?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);

        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          // Get role
          String newRole = "";
          if (selectedRole.value == dropdownItems.first) {
            newRole = Roles.MBOSS_TECHNICAL;
          }
          if (selectedRole.value == dropdownItems.elementAt(1)) {
            newRole = Roles.MBOSS_CUSTOMERCARE;
          }

          String newPassword = "123456";
          String passwordEncrypted = EncryptionHelper.encryptData(
            newPassword,
            dotenv.env["SECRET_KEY_PASSWORD_HASH"]!,
          );

          // Get text field value

          final user = UserModel(
            id: generateRandomId(8),
            fullName: fullName,
            dob: null,
            email: email,
            gender: "Male",
            phoneNumber: phoneNumber,
            role: newRole,
            createdAt: Timestamp.now(),
            address: address,
            agency: null,
            password: passwordEncrypted,
            isDelete: false,
          );

          await createMbossStaffBloc.createStaff(user);
        } else {
          DialogUtils.hide(context);
          focusNodePhone.requestFocus();
          DialogUtils.showWarningDialog(
            context: context,
            title: "Số điện thoại đã được sử dụng!",
            onClickOutSide: () {},
          );
        }
      },
    );
  }
}

enum ShowType { view, create, update }

class SearchField extends StatefulWidget {
  final Function(String) onSearch;

  const SearchField({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  void _onSearchChanged(String query) {
    // Hủy Timer cũ nếu có
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    // Tạo Timer mới
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  void dispose() {
    // Hủy Timer khi Widget bị dispose
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => _onSearchChanged(value),
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        fontFamily: 'BeVietNam',
        color: Color(0xff3C3C43),
      ),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        hintText: 'Tìm kiếm',
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'BeVietNam',
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
