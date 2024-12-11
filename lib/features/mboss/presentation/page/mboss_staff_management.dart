import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/core/widgets/fullname_formatter.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
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

  ValueNotifier<bool> isFabVisible = ValueNotifier<bool>(true);
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

  // Scroll
  final scrollController = ScrollController();

  ValueNotifier<int> ccCount = ValueNotifier<int>(0);
  ValueNotifier<int> techCount = ValueNotifier<int>(0);
  ValueNotifier<int> allCount = ValueNotifier<int>(0);

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
    scrollController.dispose();
  }

  buildSliverAppBarContent() {
    return Column(
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: allCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Tổng nhân viên",
                  value: allCount.value.toString(),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: ccCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Nhân viên CSKH",
                  value: ccCount.value.toString(),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: techCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Nhân viên kỹ thuật",
                  value: techCount.value.toString(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: isFabVisible,
        builder: (context, value, child) {
          return Visibility(
            visible: value,
            child: GestureDetector(
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
            ),
          );
        },
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              isFabVisible.value = true;
            } else if (notification.direction == ScrollDirection.reverse) {
              isFabVisible.value = false;
            }
            return true;
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  scrolledUnderElevation: 0,
                  title: null,
                  snap: true,
                  centerTitle: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  expandedHeight: 210,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 4, right: 16),
                          child: Stack(
                            children: [
                              Container(
                                height: kToolbarHeight - 4,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  "Quản Lý Nhân Viên",
                                  style: AppStyle.appBarTitle.copyWith(
                                    color: const Color(0xff820a1a),
                                  ),
                                ),
                              ),
                              Container(
                                height: kToolbarHeight,
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => context.pop(),
                                  icon: ImageHelper.loadAssetImage(
                                    AppAssets.icArrowLeft,
                                    tintColor: const Color(0xff111827),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Phần buildSliverAppBarContent
                        buildSliverAppBarContent(),
                      ],
                    ),
                  ),
                ),
              ];
            },
            controller: scrollController,
            body: Column(
              children: [
                BlocConsumer<FetchMbossStaffBloc, List<UserModel>>(
                  bloc: mbossStaffBloc,
                  listener: (context, state) {
                    if (!mbossStaffBloc.isLoading && state.isNotEmpty) {
                      final userOriginal = mbossStaffBloc.getStaffsOriginal;
                      // Update ValueNotifiers outside the build phase
                      allCount.value = userOriginal.length;
                      ccCount.value = userOriginal
                          .where(
                              (user) => user.role == Roles.MBOSS_CUSTOMERCARE)
                          .length;
                      techCount.value = userOriginal
                          .where((user) => user.role == Roles.MBOSS_TECHNICAL)
                          .length;
                    }
                  },
                  builder: (context, state) {
                    if (mbossStaffBloc.isLoading) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: const CustomerCardShimmer(),
                          ),
                        ),
                      );
                    }
                    if (!mbossStaffBloc.isLoading && state.isNotEmpty) {
                      final listUser = List.from(state);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
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
                BlocListener<CreateMbossStaffBloc, bool>(
                  listener: (context, state) async {
                    if (createMbossStaffBloc.isLoading == false &&
                        state == true) {
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
                    if (deleteMbossStaffBloc.isLoading == false &&
                        state == true) {
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
                    if (updateMbossStaffBloc.isLoading == false &&
                        state == true) {
                      DialogUtils.hide(context);
                      DialogUtils.hide(context);
                      await mbossStaffBloc.fetchMbossStaffs();
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRowInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
                            keyboardType: TextInputType.name,
                            formatter: [
                              FilteringTextInputFormatter.deny(RegExp(r'\d')),
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
                          // const SizedBox(height: 23),
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: Text(
                          //     "Lịch Sử Công Việc",
                          //     style: AppStyle.heading2.copyWith(
                          //       color: AppColors.appBarTitleColor,
                          //       fontWeight: FontWeight.w600,
                          //       fontSize: 22,
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          // Container(
                          //   alignment: Alignment.centerRight,
                          //   child: FilterDropdown(
                          //     selectedValue: 'Tháng',
                          //     onChanged: (value) =>
                          //         selectedFilter.value = value,
                          //     options: dropdownWorkHistoryItems,
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // ValueListenableBuilder(
                          //   valueListenable: selectedFilter,
                          //   builder: (context, value, child) {
                          //     Future<int> future = Future(() => 0);
                          //     if (value != null) {
                          //       future = StatsUtils.instance
                          //           .getCustomerOfStaffCountWithFilter(
                          //         staffID: user?.id ?? "",
                          //         filterValue: value,
                          //       );
                          //     }
                          //     if (value == null) {
                          //       future = StatsUtils.instance
                          //           .getCustomerOfStaffCount(user?.id ?? "");
                          //     }
                          //     return Column(
                          //       children: [
                          //         FutureBuilder<int>(
                          //           future: future,
                          //           builder: (context, snapshot) {
                          //             if (snapshot.hasData &&
                          //                 snapshot.connectionState ==
                          //                     ConnectionState.done) {
                          //               return buildRowInfoItem(
                          //                 label: "Tổng khách hàng",
                          //                 value:
                          //                     (snapshot.data ?? 0).toString(),
                          //               );
                          //             }
                          //             return const SizedBox.shrink();
                          //           },
                          //         ),
                          //         const SizedBox(height: 4),
                          //         if (user?.role == Roles.MBOSS_CUSTOMERCARE)
                          //           Padding(
                          //             padding:
                          //                 const EdgeInsets.only(bottom: 16),
                          //             child: buildRowInfoItem(
                          //               label: "Nhiệm vụ hoàn thành",
                          //               value: "0/30",
                          //             ),
                          //           ),
                          //       ],
                          //     );
                          //   },
                          // ),
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
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    " * ",
                    style: TextStyle(
                      fontFamily: "BeVietnam",
                      color: Color(0xff820a1a),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
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
                      fontWeight: FontWeight.w400,
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
                              FilteringTextInputFormatter.deny(RegExp(r'\d')),
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

  handleDeleteStaff(UserModel? user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn\nxoá nhân viên này ?",
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

        // Get role
        String newRole = "";
        if (selectedRole.value == dropdownItems.first) {
          newRole = Roles.MBOSS_TECHNICAL;
        }
        if (selectedRole.value == dropdownItems.elementAt(1)) {
          newRole = Roles.MBOSS_CUSTOMERCARE;
        }
        userUpdate.role = newRole;

        userUpdate.fullName = nameController.text.trim();
        userUpdate.address = addressController.text.trim();
        userUpdate.phoneNumber = phoneController.text.trim();
        userUpdate.email = emailController.text.trim();

        // Check email and phone exist
        bool isPhoneExisted = false;
        bool isEmailExisted = false;

        try {
          // Check if phone number exists
          final phoneQuerySnapshot = await FirebaseFirestore.instance
              .collection("users")
              .where("phoneNumber", isEqualTo: userUpdate.phoneNumber)
              .limit(1)
              .get();

          isPhoneExisted = phoneQuerySnapshot.docs.isNotEmpty &&
              phoneQuerySnapshot.docs.first.id != user.id;

          // Check if email exists
          final emailQuerySnapshot = await FirebaseFirestore.instance
              .collection("users")
              .where("email", isEqualTo: userUpdate.email)
              .limit(1)
              .get();

          isEmailExisted = emailQuerySnapshot.docs.isNotEmpty &&
              emailQuerySnapshot.docs.first.id != user.id;
        } on Exception catch (e) {
          throw Exception(e);
        } finally {
          DialogUtils.hide(context);
        }

        if (isPhoneExisted && isEmailExisted) {
          print("Both phone number and email already exist.");
        } else if (isPhoneExisted) {
          DialogUtils.showWarningDialog(
            context: context,
            title: "Số điện thoại đã được đăng ký!",
            onClickOutSide: () {},
          );
          focusNodePhone.requestFocus();
          return;
        } else if (isEmailExisted) {
          DialogUtils.showWarningDialog(
            context: context,
            title: "Email đã được đăng ký!",
            onClickOutSide: () {},
          );
        } else {
          DialogUtils.showLoadingDialog(context);
          await updateMbossStaffBloc.updateStaff(userUpdate);
        }
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
            title: "Số điện thoại đã được đăng ký!",
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
      cursorHeight: 22,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        hintText: 'Tìm kiếm',
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'BeVietNam',
          color: Colors.grey.shade500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      ),
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
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.formatter,
            style: AppStyle.bodyText.copyWith(
              color: const Color(0xffB3B3B3),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
          if (widget.isRequired && widget.controller.text.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
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
