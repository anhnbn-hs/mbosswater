import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_mboss_staff_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossStaffManagement extends StatefulWidget {
  const MbossStaffManagement({super.key});

  @override
  State<MbossStaffManagement> createState() => _MbossStaffManagementState();
}

class _MbossStaffManagementState extends State<MbossStaffManagement> {
  late FetchMbossStaffBloc mbossStaffBloc;
  late CreateMbossStaffBloc createMbossStaffBloc;

  // Controller
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  ValueNotifier<String?> selectedRole = ValueNotifier(null);
  final List<String> dropdownItems = [
    'Nhân viên kỹ thuật',
    'Nhân viên chăm sóc khách hàng'
  ];

  @override
  void initState() {
    super.initState();
    mbossStaffBloc = BlocProvider.of<FetchMbossStaffBloc>(context);
    createMbossStaffBloc = BlocProvider.of<CreateMbossStaffBloc>(context);
    mbossStaffBloc.fetchMbossStaffs();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const LeadingBackButton()),
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
      body: BlocBuilder<FetchMbossStaffBloc, List<UserModel>>(
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
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Quản Lý Nhân Viên",
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
                    child: SearchField(
                      onSearch: (value) {},
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                    height: 40,
                    thickness: .2,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
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
                    ),
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
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
            color: const Color(0xffDADADA),
          ),
        ),
        child: Column(
          children: [
            const Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                "Mã nhân viên: #111",
                style: TextStyle(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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
                          initValue: user?.fullName ?? "",
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
                          initValue: user?.phoneNumber ?? "",
                        ),
                        const SizedBox(height: 26),
                        buildBoxFieldItem(
                          hintValue: "Email",
                          initValue: user?.email ?? "",
                        ),
                        const SizedBox(height: 26),
                        buildBoxFieldItem(
                          hintValue: "Địa chỉ",
                          initValue: user?.address ?? "",
                        ),
                        const SizedBox(height: 36),
                        Expanded(
                          child: Column(
                            children: [
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
                              buildRowInfoItem(
                                  label: "Tổng khách hàng", value: "99"),
                              const SizedBox(height: 18),
                              buildRowInfoItem(
                                  label: "Nhiệm vụ hoàn thành", value: "25/30"),
                              const Spacer(),
                              Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: const Color(0xffC2C2C2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            "XÓA",
                                            style: TextStyle(
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
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            "CẬP NHẬT",
                                            style: TextStyle(
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
                        // CustomButton(
                        //   onTap: () {},
                        //   height: 40,
                        //   textButton: "TẠO TÀI KHOẢN",
                        // )
                      ],
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
    if(role != null){
      if(role == Roles.MBOSS_TECHNICAL){
        selectedRole.value = dropdownItems.first;
      }
      if(role == Roles.MBOSS_CUSTOMERCARE){
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
                    "*",
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
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
                  Padding(
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
                            hintValue: "Họ và tên", initValue: ""),
                        const SizedBox(height: 26),
                        buildBoxFieldItem(hintValue: "NVKT", initValue: ""),
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
                          initValue: "",
                        ),
                        const SizedBox(height: 26),
                        buildBoxFieldItem(
                          hintValue: "Email",
                          initValue: "",
                        ),
                        const SizedBox(height: 26),
                        buildBoxFieldItem(
                          hintValue: "Địa chỉ",
                          initValue: "",
                        ),
                        const SizedBox(height: 36),
                        CustomButton(
                          onTap: () {},
                          height: 40,
                          textButton: "TẠO TÀI KHOẢN",
                        )
                      ],
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
    required String? initValue,
    TextEditingController? controller,
  }) {
    return Container(
      height: 34,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff757575)),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initValue,
        style: AppStyle.bodyText.copyWith(
          color: const Color(0xffB3B3B3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
          hintText: hintValue,
          hintStyle: AppStyle.bodyText.copyWith(
            color: const Color(0xffB3B3B3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
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
