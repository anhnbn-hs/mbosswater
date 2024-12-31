import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/search_field.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/agency/presentation/bloc/create_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/delete_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/update_agency_staff_bloc.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/customer_info_step.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class AgencyStaffManagement extends StatefulWidget {
  const AgencyStaffManagement({super.key});

  @override
  State<AgencyStaffManagement> createState() => _AgencyStaffManagementState();
}

class _AgencyStaffManagementState extends State<AgencyStaffManagement> {
  late FetchAgencyStaffBloc fetchAgencyStaffBloc;
  late CreateAgencyStaffBloc createAgencyStaffBloc;
  late UpdateAgencyStaffBloc updateAgencyStaffBloc;
  late DeleteAgencyStaffBloc deleteAgencyStaffBloc;
  late UserInfoBloc userInfoBloc;
  late ProvincesBloc provincesUserBloc;
  late DistrictsBloc districtsUserBloc;
  late CommunesBloc communesUserBloc;

  // Controller
  final searchController = TextEditingController();

  PageController pageController = PageController();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressDetailController = TextEditingController();
  final cccdController = TextEditingController();

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

  ValueNotifier<int> staffCount = ValueNotifier<int>(0);
  ValueNotifier<int> sellerCount = ValueNotifier<int>(0);
  ValueNotifier<int> techCount = ValueNotifier<int>(0);

  ValueNotifier<bool> isDistrictsUserFetched = ValueNotifier(false);

  final GlobalKey _sliverAppBarContentKey = GlobalKey();
  double _sliverAppBarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    fetchAgencyStaffBloc = BlocProvider.of<FetchAgencyStaffBloc>(context);
    createAgencyStaffBloc = BlocProvider.of<CreateAgencyStaffBloc>(context);
    updateAgencyStaffBloc = BlocProvider.of<UpdateAgencyStaffBloc>(context);
    deleteAgencyStaffBloc = BlocProvider.of<DeleteAgencyStaffBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    provincesUserBloc = BlocProvider.of<ProvincesBloc>(context);
    districtsUserBloc = BlocProvider.of<DistrictsBloc>(context);
    communesUserBloc = BlocProvider.of<CommunesBloc>(context);
    if (provincesUserBloc.state is! ProvincesLoaded) {
      provincesUserBloc.add(FetchProvinces());
    }
    fetchAgencyStaffBloc.fetchAgencyStaffs(userInfoBloc.user?.agency ?? "");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSliverAppBarHeight();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressDetailController.dispose();
    cccdController.dispose();
    focusNodeName.dispose();
    focusNodePhone.dispose();
    focusNodeAddress.dispose();
    scrollController.dispose();
  }

  void _calculateSliverAppBarHeight() {
    final RenderBox? renderBox = _sliverAppBarContentKey.currentContext
        ?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _sliverAppBarHeight = renderBox.size.height + kToolbarHeight;
      });
    }
  }

  buildSliverAppBarContent() {
    return Column(
      key: _sliverAppBarContentKey,
      children: [
        Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SearchField(
            hint: "Tìm kiếm theo tên hoặc số điện thoại",
            controller: searchController,
            onSearch: (value) {
              fetchAgencyStaffBloc.searchStaff(value);
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
                valueListenable: staffCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Tổng nhân viên",
                  value: value.toString(),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: sellerCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Nhân viên bán hàng",
                  value: value.toString(),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: techCount,
                builder: (context, value, child) => buildRowInfoItem(
                  label: "Nhân viên kỹ thuật",
                  value: value.toString(),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: GestureDetector(
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
      body: SafeArea(
        child: NestedScrollView(
          controller: scrollController,
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
                expandedHeight: _sliverAppBarHeight,
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: BlocConsumer<FetchAgencyStaffBloc, List<UserModel>>(
                    bloc: fetchAgencyStaffBloc,
                    listener: (context, state) {
                      if (!fetchAgencyStaffBloc.isLoading && state.isNotEmpty) {
                        final userOriginal =
                            fetchAgencyStaffBloc.getStaffsOriginal;
                        // Update ValueNotifiers outside the build phase
                        staffCount.value = userOriginal.length;
                        sellerCount.value = userOriginal
                            .where((user) => user.role == Roles.AGENCY_STAFF)
                            .length;
                        techCount.value = userOriginal
                            .where(
                                (user) => user.role == Roles.AGENCY_TECHNICAL)
                            .length;
                      }
                    },
                    builder: (context, state) {
                      if (fetchAgencyStaffBloc.isLoading) {
                        return ListView.builder(
                          itemCount: 8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: const CustomerCardShimmer(),
                          ),
                        );
                      }
                      if (!fetchAgencyStaffBloc.isLoading) {
                        final listUser = state;
                        if (listUser.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Text(
                              "Không có nhân viên nào!",
                              style: AppStyle.bodyText,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              ListView.builder(
                                itemCount: listUser.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
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
                ),
              ),
              // Listener for create
              BlocListener<CreateAgencyStaffBloc, bool>(
                listener: (context, state) async {
                  if (createAgencyStaffBloc.isLoading == false &&
                      state == true) {
                    DialogUtils.hide(context);
                    DialogUtils.hide(context);
                    await fetchAgencyStaffBloc
                        .fetchAgencyStaffs(userInfoBloc.user?.agency ?? "");
                  }
                },
                child: const SizedBox.shrink(),
              ),
              // Listener for delete
              BlocListener<DeleteAgencyStaffBloc, bool>(
                listener: (context, state) async {
                  if (deleteAgencyStaffBloc.isLoading == false &&
                      state == true) {
                    DialogUtils.hide(context);
                    DialogUtils.hide(context);
                    await fetchAgencyStaffBloc
                        .fetchAgencyStaffs(userInfoBloc.user?.agency ?? "");
                  }
                },
                child: const SizedBox.shrink(),
              ),
              // Listener for update
              BlocListener<UpdateAgencyStaffBloc, bool>(
                listener: (context, state) async {
                  if (updateAgencyStaffBloc.isLoading == false &&
                      state == true) {
                    DialogUtils.hide(context);
                    DialogUtils.hide(context);
                    await fetchAgencyStaffBloc
                        .fetchAgencyStaffs(userInfoBloc.user?.agency ?? "");
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
    if (role == Roles.AGENCY_STAFF) {
      return "Nhân viên bán hàng";
    }
    if (role == Roles.AGENCY_TECHNICAL) {
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
            color: user.role == Roles.AGENCY_TECHNICAL
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
    addressDetailController.text = user?.address?.detail ?? "";
    emailController.text = user?.email ?? "";
    cccdController.text = user?.cccd ?? "";

    await showModalBottomSheet(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 70,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(
                    left: 150,
                    right: 150,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                ),
                Positioned(
                  top: 36,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          TextFieldLabelItem(
                            label: "Họ và tên",
                            hint: "Họ và tên",
                            controller: nameController,
                            focusNode: focusNodeName,
                            inputType: TextInputType.name,
                            formatter: [
                              FilteringTextInputFormatter.deny(RegExp(r'\d')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              children: [
                                Text(
                                  "Chức vụ",
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(fontSize: 15),
                                ),
                                Text(
                                  " * ",
                                  style: AppStyle.boxFieldLabel.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildRoleSelection(user?.role),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "CCCD",
                            hint: "Số CMT/CCCD",
                            isRequired: false,
                            controller: cccdController,
                            inputType: TextInputType.number,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
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
                          TextFieldLabelItem(
                            label: "Số điện thoại",
                            hint: "Số điện thoại",
                            controller: phoneController,
                            focusNode: focusNodePhone,
                            inputType: TextInputType.phone,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              children: [
                                Text(
                                  "Địa chỉ",
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(fontSize: 15),
                                ),
                                Text(
                                  " * ",
                                  style: AppStyle.boxFieldLabel.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder(
                              bloc: provincesUserBloc,
                              builder: (context, state) {
                                if (provincesUserBloc.selectedProvince ==
                                    null) {
                                  provincesUserBloc.selectProvince(
                                    provincesUserBloc.getProvinceByName(
                                            user?.address?.province ?? "") ??
                                        Province(),
                                  );
                                  districtsUserBloc.add(FetchDistricts(
                                      provincesUserBloc.selectedProvince?.id ??
                                          ""));
                                }
                                return buildAddressItem(
                                  label: provincesUserBloc
                                          .selectedProvince?.name ??
                                      "Tỉnh/TP",
                                  addressType: AddressType.province,
                                );
                              }),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: isDistrictsUserFetched,
                            builder: (context, value, child) {
                              return BlocConsumer(
                                bloc: districtsUserBloc,
                                listener: (context, state) {
                                  if (state is DistrictsLoaded) {
                                    isDistrictsUserFetched.value = true;
                                    if (districtsUserBloc.selectedDistrict ==
                                        null) {
                                      districtsUserBloc.selectDistrict(
                                        districtsUserBloc.getDistrictByName(
                                                user?.address?.district ??
                                                    "") ??
                                            District(),
                                      );
                                      communesUserBloc.add(FetchCommunes(
                                          districtsUserBloc
                                                  .selectedDistrict?.id ??
                                              ""));
                                    }
                                  }
                                },
                                builder: (context, state) => buildAddressItem(
                                  label: districtsUserBloc
                                          .selectedDistrict?.name ??
                                      "Quận/Huyện",
                                  addressType: AddressType.district,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: isDistrictsUserFetched,
                            builder: (context, value, child) {
                              return BlocConsumer(
                                bloc: communesUserBloc,
                                listener: (context, state) {
                                  if (state is CommunesLoaded) {
                                    if (communesUserBloc.selectedCommune ==
                                        null) {
                                      communesUserBloc.selectCommune(
                                        communesUserBloc.getCommuneByName(
                                                user?.address?.commune ?? "") ??
                                            Commune(),
                                      );
                                    }
                                  }
                                },
                                builder: (context, state) => buildAddressItem(
                                  label:
                                      communesUserBloc.selectedCommune?.name ??
                                          "Phường/Xã",
                                  addressType: AddressType.commune,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFieldLabelItem(
                            label: "Địa chỉ chi tiết",
                            hint: "Địa chỉ chi tiết",
                            controller: addressDetailController,
                            focusNode: focusNodeAddress,
                          ),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "Email",
                            hint: "Email",
                            isRequired: false,
                            controller: emailController,
                            inputType: TextInputType.emailAddress,
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
                          const SizedBox(height: 28),
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
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.primaryColor,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then(
      (value) {
        selectedRole.value = null;
        provincesUserBloc.selectedProvince = null;
        districtsUserBloc.selectedDistrict = null;
        communesUserBloc.selectedCommune = null;
      },
    );
  }

  Widget buildRoleSelection(String? role) {
    if (role != null) {
      if (role == Roles.AGENCY_STAFF) {
        selectedRole.value = dropdownItems.first;
      }
      if (role == Roles.AGENCY_TECHNICAL) {
        selectedRole.value = dropdownItems.elementAt(1);
      }
    }
    return Container(
      height: 40,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffBDBDBD),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: selectedRole,
        builder: (context, value, child) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              value: selectedRole.value,
              hint: Text(
                "Chọn chức vụ",
                style: AppStyle.boxField.copyWith(
                  color: Colors.black54,
                  fontSize: 15,
                ),
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
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontSize: 15,
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
    addressDetailController.text = "";
    emailController.text = "";
    cccdController.text = "";

    await showModalBottomSheet(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 70,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(
                    left: 150,
                    right: 150,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                ),
                Positioned(
                  top: 36,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          TextFieldLabelItem(
                            label: "Họ và tên",
                            hint: "Họ và tên",
                            isRequired: true,
                            controller: nameController,
                            formatter: [
                              FilteringTextInputFormatter.deny(RegExp(r'\d')),
                            ],
                            focusNode: focusNodeName,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              children: [
                                Text(
                                  "Chức vụ",
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(fontSize: 15),
                                ),
                                Text(
                                  " * ",
                                  style: AppStyle.boxFieldLabel.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildRoleSelection(null),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "CCCD",
                            hint: "Số CMT/CCCD",
                            isRequired: false,
                            controller: cccdController,
                            inputType: TextInputType.number,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 28),
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
                          TextFieldLabelItem(
                            hint: "Số điện thoại",
                            label: "Số điện thoại",
                            isRequired: true,
                            controller: phoneController,
                            focusNode: focusNodePhone,
                            inputType: TextInputType.phone,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              children: [
                                Text(
                                  "Địa chỉ",
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(fontSize: 15),
                                ),
                                Text(
                                  " * ",
                                  style: AppStyle.boxFieldLabel.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder(
                            bloc: provincesUserBloc,
                            builder: (context, state) {
                              return buildAddressItem(
                                label:
                                    provincesUserBloc.selectedProvince?.name ??
                                        "Tỉnh/TP",
                                addressType: AddressType.province,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder(
                            bloc: districtsUserBloc,
                            builder: (context, state) => buildAddressItem(
                              label: districtsUserBloc.selectedDistrict?.name ??
                                  "Quận/Huyện",
                              addressType: AddressType.district,
                            ),
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder(
                            bloc: communesUserBloc,
                            builder: (context, state) => buildAddressItem(
                              label: communesUserBloc.selectedCommune?.name ??
                                  "Phường/Xã",
                              addressType: AddressType.commune,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            hint: "Địa chỉ chi tiết",
                            label: "Địa chỉ chi tiết",
                            controller: addressDetailController,
                          ),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "Email",
                            hint: "Email",
                            isRequired: false,
                            controller: emailController,
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            onTap: () async => handleCreateStaff(),
                            textButton: "TẠO TÀI KHOẢN",
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.primaryColor,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then(
      (value) {
        selectedRole.value = null;
        provincesUserBloc.selectedProvince = null;
        districtsUserBloc.selectedDistrict = null;
        communesUserBloc.selectedCommune = null;
      },
    );
  }

  handleDeleteStaff(UserModel? user) async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn xoá nhân viên này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        await deleteAgencyStaffBloc.deleteStaff(user?.id ?? "");
      },
    );
  }

  handleUpdateStaff(UserModel user) async {
    String fullName = nameController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String addressDetail = addressDetailController.text.trim();
    String cccd = cccdController.text.trim();

    if (fullName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập tên nhân viên",
        onClickOutSide: () {},
      );
      focusNodeName.requestFocus();
      return;
    }

    if (selectedRole.value == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn chức vụ của nhân viên",
        onClickOutSide: () {},
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại của nhân viên",
        onClickOutSide: () {},
      );
      focusNodePhone.requestFocus();
      return;
    }

    if (provincesUserBloc.selectedProvince == null ||
        districtsUserBloc.selectedDistrict == null ||
        communesUserBloc.selectedCommune == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn địa chỉ nhân viên",
        onClickOutSide: () {},
      );
      return;
    }

    if (addressDetail.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ chi tiết của nhân viên",
        onClickOutSide: () {},
      );
      focusNodeAddress.requestFocus();
      return;
    }

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
          newRole = Roles.AGENCY_STAFF;
        }
        if (selectedRole.value == dropdownItems.elementAt(1)) {
          newRole = Roles.AGENCY_TECHNICAL;
        }
        userUpdate.role = newRole;

        userUpdate.fullName = nameController.text.trim();
        userUpdate.address = Address(
          province: provincesUserBloc.selectedProvince?.name,
          district: districtsUserBloc.selectedDistrict?.name,
          commune: communesUserBloc.selectedCommune?.name,
          detail: addressDetailController.text.trim(),
        );
        userUpdate.phoneNumber = phoneController.text.trim();
        userUpdate.email = emailController.text.trim();
        userUpdate.cccd = cccd;

        // Check email and phone exist
        bool isPhoneExisted = false;
        bool isEmailExisted = false;

        try {
          // Check if phone number exists
          final phoneQuerySnapshot = await FirebaseFirestore.instance
              .collection("users")
              .where("phoneNumber", isEqualTo: userUpdate.phoneNumber)
              .where("isDelete", isEqualTo: false)
              .limit(1)
              .get();

          isPhoneExisted = phoneQuerySnapshot.docs.isNotEmpty &&
              phoneQuerySnapshot.docs.first.id != user.id;

          // Check if email exists
          final emailQuerySnapshot = await FirebaseFirestore.instance
              .collection("users")
              .where("email", isEqualTo: userUpdate.email)
              .where("isDelete", isEqualTo: false)
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
          await updateAgencyStaffBloc.updateStaff(userUpdate);
        }
      },
    );
  }

  handleCreateStaff() async {
    String fullName = nameController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String address = addressDetailController.text.trim();
    String email = emailController.text.trim();
    String cccd = cccdController.text.trim();

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
        title: "Hãy chọn chức vụ của nhân viên",
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

    if (address.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ chi tiết",
        onClickOutSide: () {},
      );
      focusNodeAddress.requestFocus();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận thêm mới nhân viên này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);

        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: phoneNumber)
            .where("isDelete", isEqualTo: false)
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          // Check if email exists
          if (email.isNotEmpty) {
            final emailQuerySnapshot = await FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: email)
                .where("isDelete", isEqualTo: false)
                .limit(1)
                .get();

            bool isEmailExisted = emailQuerySnapshot.docs.isNotEmpty;
            if (isEmailExisted) {
              DialogUtils.hide(context);
              focusNodePhone.requestFocus();
              DialogUtils.showWarningDialog(
                context: context,
                title: "Email đã được đăng ký!",
                onClickOutSide: () {},
              );
              return;
            }
          }

          // Get role
          String newRole = "";
          if (selectedRole.value == dropdownItems.first) {
            newRole = Roles.AGENCY_STAFF;
          }
          if (selectedRole.value == dropdownItems.elementAt(1)) {
            newRole = Roles.AGENCY_TECHNICAL;
          }

          final address = Address(
            province: provincesUserBloc.selectedProvince?.name,
            district: districtsUserBloc.selectedDistrict?.name,
            commune: communesUserBloc.selectedCommune?.name,
            detail: addressDetailController.text.trim(),
          );

          String newPassword = "123456";
          String passwordEncrypted = EncryptionHelper.encryptData(
            newPassword,
            dotenv.env["SECRET_KEY_PASSWORD_HASH"]!,
          );

          // Get text field value

          final user = UserModel(
            id: generateRandomId(6),
            fullName: fullName,
            cccd: cccd,
            dob: null,
            email: email,
            gender: "Male",
            phoneNumber: phoneNumber,
            role: newRole,
            createdAt: Timestamp.now(),
            address: address,
            agency: userInfoBloc.user?.agency ?? "",
            password: passwordEncrypted,
            isDelete: false,
          );

          await createAgencyStaffBloc.createStaff(user);
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

  Widget buildAddressItem({
    required String label,
    required AddressType addressType,
    bool isEnable = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (isEnable) {
          showBottomSheetChooseAddress(
            context: context,
            addressType: addressType,
            pageController: pageController,
            provincesBloc: provincesUserBloc,
            districtsBloc: districtsUserBloc,
            communesBloc: communesUserBloc,
          );
        }
      },
      child: Container(
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: !isEnable ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xffBDBDBD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: AppStyle.boxField.copyWith(
                    color:
                        ["Tỉnh/TP", "Quận/Huyện", "Phường/Xã"].contains(label)
                            ? const Color(0xff828282)
                            : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    if (["Tỉnh/TP", "Quận/Huyện", "Phường/Xã"].contains(label))
                      const TextSpan(
                        text: " * ",
                        style: TextStyle(
                          color: Color(0xff8A0E1E),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}

enum ShowType { view, create, update }


