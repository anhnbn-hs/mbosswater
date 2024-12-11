import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/fullname_formatter.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/page/mboss_staff_management.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class AgencyStaffManagement extends StatefulWidget {
  const AgencyStaffManagement({super.key});

  @override
  State<AgencyStaffManagement> createState() => _AgencyStaffManagementState();
}

class _AgencyStaffManagementState extends State<AgencyStaffManagement> {
  late FetchAgencyStaffBloc fetchAgencyStaffBloc;
  late UserInfoBloc userInfoBloc;

  // Controller
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  ValueNotifier<bool> isShowFab = ValueNotifier(true);
  ValueNotifier<String?> selectedRole = ValueNotifier(null);
  final List<String> dropdownItems = [
    'Nhân viên bán hàng',
    'Nhân viên kỹ thuật'
  ];
  final scrollController = ScrollController();

  // Focus node
  final focusNodeName = FocusNode();
  final focusNodePhone = FocusNode();
  final focusNodeAddress = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchAgencyStaffBloc = BlocProvider.of<FetchAgencyStaffBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    fetchAgencyStaffBloc.fetchAgencyStaffs(userInfoBloc.user?.agency ?? "");
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
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const LeadingBackButton(),
        centerTitle: true,
        title: Text(
          "Quản Lý Nhân Viên",
          style:
              AppStyle.appBarTitle.copyWith(color: AppColors.appBarTitleColor),
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: isShowFab,
        builder: (context, value, child) {
          if (!value) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () async => await showStaffCreation(),
            child: Container(
              margin: const EdgeInsets.only(right: 10, bottom: 16),
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
          );
        },
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const SizedBox(height: 30),
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
                  // fetchAgencyStaffBloc.searchStaff(value);
                },
              ),
            ),
            Divider(
              color: Colors.grey.shade400,
              height: 44,
              thickness: .2,
            ),
            BlocBuilder<FetchAgencyStaffBloc, List<UserModel>>(
              bloc: fetchAgencyStaffBloc,
              builder: (context, state) {
                if (fetchAgencyStaffBloc.isLoading) {
                  return Center(
                    child: Lottie.asset(AppAssets.aLoading, height: 50),
                  );
                }
                if (!fetchAgencyStaffBloc.isLoading) {
                  final listUser = state;
                  if (listUser.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text(
                        "Đại lý của bạn chưa có nhân viên nào!",
                        style: AppStyle.bodyText,
                      ),
                    );
                  }

                  int staffCount = listUser
                      .where((user) => user.role == Roles.AGENCY_STAFF)
                      .length;
                  int techCount = listUser
                      .where((user) => user.role == Roles.AGENCY_TECHNICAL)
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
                          value: staffCount.toString(),
                        ),
                        buildRowInfoItem(
                          label: "Nhân viên kỹ thuật",
                          value: techCount.toString(),
                        ),
                        const SizedBox(height: 30),
                        ListView.builder(
                          itemCount: listUser.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: buildStaffItem(listUser[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Listener for create

            // Listener for delete

            // Listener for update
          ],
        ),
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
            Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Mã nhân viên: #${user.id.substring(0, 6).toUpperCase()}",
                style: const TextStyle(
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
          margin: const EdgeInsets.only(left: 0, right: 0),
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: MediaQuery.of(context).size.height - 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 36),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Nhân Viên",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Họ và tên",
                            controller: nameController,
                            focusNode: focusNodeName,
                            formatter: [
                              FullNameInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 23),
                          buildRoleSelection(user?.role),
                          const SizedBox(height: 23),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Liên Hệ",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Số điện thoại",
                            controller: phoneController,
                            focusNode: focusNodePhone,
                            keyboardType: TextInputType.phone,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Địa chỉ",
                            controller: addressController,
                            focusNode: focusNodeAddress,
                          ),
                          const SizedBox(height: 36),
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
                          const SizedBox(height: 40),
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

  Widget buildRoleSelection(String? role) {
    if (role != null) {
      if (role == Roles.MBOSS_TECHNICAL) {
        selectedRole.value = dropdownItems.first;
      }
      if (role == Roles.MBOSS_CUSTOMERCARE) {
        selectedRole.value = dropdownItems.elementAt(1);
      }
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
                      color: Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    " * ",
                    style: TextStyle(
                      color: Color(0xff820a1a),
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
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 70,
              padding: const EdgeInsets.only(bottom: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Họ và tên",
                            isRequired: true,
                            controller: nameController,
                            formatter: [
                              FullNameInputFormatter(),
                            ],
                            focusNode: focusNodeName,
                          ),
                          const SizedBox(height: 23),
                          buildRoleSelection(null),
                          const SizedBox(height: 23),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Liên Hệ",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                              hintValue: "Số điện thoại",
                              isRequired: true,
                              controller: phoneController,
                              focusNode: focusNodePhone,
                              keyboardType: TextInputType.phone,
                              formatter: [
                                FilteringTextInputFormatter.digitsOnly
                              ]),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Email",
                            controller: emailController,
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Địa chỉ",
                            controller: addressController,
                          ),
                          const SizedBox(height: 36),
                          CustomButton(
                            onTap: () async => handleCreateStaff(),
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

  handleDeleteStaff(UserModel? user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn xóa nhân viên: ${user?.fullName}?",
      textCancelButton: "Hủy",
      textAcceptButton: "Xóa",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        // await deleteMbossStaffBloc.deleteStaff(user?.id ?? "");
      },
    );
  }

  handleUpdateStaff(UserModel user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn cập nhật nhân viên: ${user.fullName}?",
      textCancelButton: "Hủy",
      textAcceptButton: "Cập nhật",
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
        // await updateMbossStaffBloc.updateStaff(userUpdate);
      },
    );
  }

  handleCreateStaff() async {
    String fullName = nameController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String address = addressController.text.trim();
    String email = emailController.text.trim();

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận thêm mới nhân viên: $fullName?",
      textCancelButton: "Hủy",
      textAcceptButton: "Thêm",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        // Get role
        String newRole = "";
        if (selectedRole.value == dropdownItems.first) {
          newRole = Roles.MBOSS_TECHNICAL;
        }
        if (selectedRole.value == dropdownItems.elementAt(1)) {
          newRole = Roles.MBOSS_CUSTOMERCARE;
        }
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
          password: "123456",
          isDelete: false,
        );

        // await createMbossStaffBloc.createStaff(user);
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
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
      ),
    );
  }
}
