import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/constants/constants.dart';
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
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/agency/presentation/page/agency_staff_management.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/customer_info_step.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossAgencyManagement extends StatefulWidget {
  const MbossAgencyManagement({super.key});

  @override
  State<MbossAgencyManagement> createState() => _MbossAgencyManagementState();
}

class _MbossAgencyManagementState extends State<MbossAgencyManagement> {
  // Value Notifier
  ValueNotifier<String?> selectedDateFilter = ValueNotifier(null);
  ValueNotifier<String?> selectedSortFilter = ValueNotifier(null);
  ValueNotifier<int> agencyCount = ValueNotifier<int>(0);

  // Bloc
  late FetchAgenciesBloc fetchAgenciesBloc;
  late CreateAgencyBloc createAgencyBloc;

  // Address BLOC
  late ProvincesAgencyBloc provincesAgencyBloc;
  late DistrictsAgencyBloc districtsAgencyBloc;
  late CommunesAgencyBloc communesAgencyBloc;

  late ProvincesBloc provincesUserBloc;
  late DistrictsBloc districtsUserBloc;
  late CommunesBloc communesUserBloc;

  // Text editing controller
  final agencyNameController = TextEditingController();
  final agencyAddressController = TextEditingController();
  final agencyBossNameController = TextEditingController();
  final agencyBossPhoneController = TextEditingController();
  final agencyBossEmailController = TextEditingController();
  final agencyBossAddressController = TextEditingController();

  PageController pageController = PageController();

  // FocusNode
  final agencyNameFocusNode = FocusNode();
  final agencyAddressFocusNode = FocusNode();
  final agencyBossNameFocusNode = FocusNode();
  final agencyBossPhoneFocusNode = FocusNode();
  final agencyBossAddressFocusNode = FocusNode();

  final GlobalKey _sliverAppBarContentKey = GlobalKey();
  double _sliverAppBarHeight = kToolbarHeight;
  @override
  void initState() {
    super.initState();
    createAgencyBloc = BlocProvider.of<CreateAgencyBloc>(context);
    fetchAgenciesBloc = BlocProvider.of<FetchAgenciesBloc>(context);
    fetchAgenciesBloc.fetchAllAgencies();

    provincesAgencyBloc = BlocProvider.of<ProvincesAgencyBloc>(context);
    districtsAgencyBloc = BlocProvider.of<DistrictsAgencyBloc>(context);
    communesAgencyBloc = BlocProvider.of<CommunesAgencyBloc>(context);

    provincesUserBloc = BlocProvider.of<ProvincesBloc>(context);
    districtsUserBloc = BlocProvider.of<DistrictsBloc>(context);
    communesUserBloc = BlocProvider.of<CommunesBloc>(context);

    if (provincesAgencyBloc.state is! ProvincesLoaded) {
      provincesAgencyBloc.add(FetchProvinces());
    }
    if (provincesUserBloc.state is! ProvincesLoaded) {
      provincesUserBloc.add(FetchProvinces());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSliverAppBarHeight();
    });
  }

  void _calculateSliverAppBarHeight() {
    final RenderBox? renderBox =
    _sliverAppBarContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _sliverAppBarHeight = renderBox.size.height + kToolbarHeight;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    agencyNameController.dispose();
    agencyAddressController.dispose();
    agencyBossNameController.dispose();
    agencyBossPhoneController.dispose();
    agencyBossEmailController.dispose();
    agencyBossAddressController.dispose();
    agencyNameFocusNode.dispose();
    agencyAddressFocusNode.dispose();
    agencyBossNameFocusNode.dispose();
    agencyBossPhoneFocusNode.dispose();
    agencyBossAddressFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: GestureDetector(
        onTap: () async => await showAgencyCreation(),
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
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                                "Danh Sách Đại Lý",
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              bool isScrollable = constraints.maxHeight <
                  MediaQuery.of(context).size.height - 300;
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: isScrollable
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: BlocConsumer<FetchAgenciesBloc, List<Agency>>(
                        bloc: fetchAgenciesBloc,
                        listener: (context, state) {
                          if (!fetchAgenciesBloc.isLoading) {
                            agencyCount.value = fetchAgenciesBloc.state.length;
                          }
                        },
                        builder: (context, state) {
                          if (fetchAgenciesBloc.isLoading) {
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

                          if (!fetchAgenciesBloc.isLoading &&
                              state.isNotEmpty) {
                            List<Agency> agencyOriginal =
                                fetchAgenciesBloc.getAgenciesOriginal;
                            List<Agency> agencyFiltered = List.from(
                                state); // Initialize with search result

                            // Apply sort filter
                            if (selectedSortFilter.value != null) {
                              if (selectedSortFilter.value == "Mới nhất") {
                                agencyFiltered.sort((a, b) => b.createdAt
                                    .toDate()
                                    .compareTo(a.createdAt.toDate()));
                              } else {
                                agencyFiltered.sort((a, b) => a.createdAt
                                    .toDate()
                                    .compareTo(b.createdAt.toDate()));
                              }
                            }

                            // Apply date filter
                            if (selectedDateFilter.value != null) {
                              final now = DateTime.now()
                                  .toUtc()
                                  .add(const Duration(hours: 7));
                              if (selectedDateFilter.value ==
                                  filterByDateItems.elementAt(1)) {
                                agencyFiltered = agencyFiltered.where((item) {
                                  final createdAt = item.createdAt.toDate();
                                  return createdAt.year == now.year &&
                                      createdAt.month == now.month;
                                }).toList();
                              } else if (selectedDateFilter.value ==
                                  filterByDateItems.elementAt(2)) {
                                final last30Days =
                                    now.subtract(const Duration(days: 30));
                                agencyFiltered = agencyFiltered.where((item) {
                                  final createdAt = item.createdAt.toDate();
                                  return createdAt.isAfter(last30Days) &&
                                      createdAt.isBefore(now);
                                }).toList();
                              } else if (selectedDateFilter.value ==
                                  filterByDateItems.elementAt(3)) {
                                final last90Days =
                                    now.subtract(const Duration(days: 90));
                                agencyFiltered = agencyFiltered.where((item) {
                                  final createdAt = item.createdAt.toDate();
                                  return createdAt.isAfter(last90Days) &&
                                      createdAt.isBefore(now);
                                }).toList();
                              } else if (selectedDateFilter.value ==
                                  filterByDateItems.elementAt(4)) {
                                agencyFiltered = agencyFiltered.where((item) {
                                  final createdAt = item.createdAt.toDate();
                                  return createdAt.year == now.year;
                                }).toList();
                              }
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                itemCount: agencyFiltered.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 22),
                                    child:
                                        buildAgencyBox(agencyFiltered[index]),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  // Listener for create
                  BlocListener<CreateAgencyBloc, bool>(
                    listener: (context, state) async {
                      if (createAgencyBloc.isLoading == false &&
                          state == true) {
                        DialogUtils.hide(context);
                        DialogUtils.hide(context);
                        agencyNameController.text = "";
                        agencyAddressController.text = "";
                        agencyBossNameController.text = "";
                        agencyBossPhoneController.text = "";
                        agencyBossEmailController.text = "";
                        await fetchAgenciesBloc.fetchAllAgencies();
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSliverAppBarContent() {
    return Column(
      key: _sliverAppBarContentKey,
      children: [
        const SizedBox(height: 10),
        Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SearchField(
            hint: "Tìm kiếm theo tên hoặc địa chỉ",
            onSearch: (value) {
              fetchAgenciesBloc.searchAgency(value.trim().toLowerCase());
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                valueListenable: selectedSortFilter,
                builder: (context, value, child) {
                  return FilterDropdown(
                    selectedValue: selectedSortFilter.value ?? "Mới nhất",
                    options: const ["Mới nhất", "Cũ nhất"],
                    onChanged: (value) {
                      setState(() {
                        selectedSortFilter.value = value;
                      });
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: selectedDateFilter,
                builder: (context, value, child) {
                  return FilterDropdown(
                    selectedValue: selectedDateFilter.value ?? "Tất cả",
                    options: filterByDateItems,
                    onChanged: (value) {
                      setState(() {
                        selectedDateFilter.value = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ValueListenableBuilder(
            valueListenable: agencyCount,
            builder: (context, value, child) => buildRowInfoItem(
              label: "Tổng số lượng đại lý",
              value: agencyCount.value.toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAgencyBox(Agency agency) {
    return GestureDetector(
      onTap: () {
        context.push(
          "/mboss-edit-agency",
          extra: agency,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    agency.name,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: "BeVietnam",
                      color: Color(0xff820a1a),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat("dd/MM/yyyy").format(agency.createdAt.toDate()),
                  style: const TextStyle(
                    fontFamily: "BeVietnam",
                    color: Color(0xff820a1a),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildRowInfoItem(
              label: "Mã đại lý",
              value: agency.code,
            ),
            buildRowInfoItem(
              label: "Địa chỉ",
              value: agency.address?.displayAddress() ?? "",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowInfoItem({required String label, required String value}) {
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

  showAgencyCreation() async {
    showModalBottomSheet(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Thông Tin Đại Lý",
                            style: AppStyle.heading2.copyWith(
                              color: AppColors.appBarTitleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 23),
                        TextFieldLabelItem(
                          label: "Tên đại lý",
                          hint: "Tên đại lý",
                          isRequired: true,
                          controller: agencyNameController,
                          focusNode: agencyNameFocusNode,
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
                          bloc: provincesAgencyBloc,
                          builder: (context, state) => buildAddressItem(
                            label: provincesAgencyBloc.selectedProvince?.name ??
                                "Tỉnh/TP",
                            addressType: AddressType.province,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder(
                          bloc: districtsAgencyBloc,
                          builder: (context, state) => buildAddressItem(
                            label: districtsAgencyBloc.selectedDistrict?.name ??
                                "Quận/Huyện",
                            addressType: AddressType.district,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder(
                          bloc: communesAgencyBloc,
                          builder: (context, state) => buildAddressItem(
                            label: communesAgencyBloc.selectedCommune?.name ??
                                "Phường/Xã",
                            addressType: AddressType.commune,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Địa chỉ chi tiết",
                          hint: "Địa chỉ chi tiết",
                          isRequired: true,
                          controller: agencyAddressController,
                          focusNode: agencyAddressFocusNode,
                        ),
                        const SizedBox(height: 23),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Thông Tin Chủ Đại Lý",
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
                          controller: agencyBossNameController,
                          focusNode: agencyBossNameFocusNode,
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Số điện thoại",
                          hint: "Số điện thoại",
                          isRequired: true,
                          controller: agencyBossPhoneController,
                          focusNode: agencyBossPhoneFocusNode,
                          inputType: TextInputType.phone,
                          formatter: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                          builder: (context, state) => buildAddressItem(
                            isAgency: false,
                            label: provincesUserBloc.selectedProvince?.name ??
                                "Tỉnh/TP",
                            addressType: AddressType.province,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder(
                          bloc: districtsUserBloc,
                          builder: (context, state) => buildAddressItem(
                            isAgency: false,
                            label: districtsUserBloc.selectedDistrict?.name ??
                                "Quận/Huyện",
                            addressType: AddressType.district,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder(
                          bloc: communesUserBloc,
                          builder: (context, state) => buildAddressItem(
                            isAgency: false,
                            label: communesUserBloc.selectedCommune?.name ??
                                "Phường/Xã",
                            addressType: AddressType.commune,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Địa chỉ chi tiết",
                          hint: "Địa chỉ chi tiết",
                          isRequired: true,
                          controller: agencyBossAddressController,
                          focusNode: agencyBossAddressFocusNode,
                        ),
                        const SizedBox(height: 12),
                        TextFieldLabelItem(
                          label: "Email",
                          hint: "Email",
                          isRequired: false,
                          controller: agencyBossEmailController,
                        ),
                        const SizedBox(height: 28),
                        CustomButton(
                          onTap: () async => handleCreateAgency(),
                          textButton: "THÊM ĐẠI LÝ",
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
        );
      },
    );
  }

  Widget buildAddressItem({
    required String label,
    required AddressType addressType,
    bool isAgency = true,
    bool isEnable = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (isEnable && isAgency) {
          showBottomSheetChooseAddressAgency(
            context: context,
            addressType: addressType,
            pageController: pageController,
            provincesAgencyBloc: provincesAgencyBloc,
            districtsAgencyBloc: districtsAgencyBloc,
            communesAgencyBloc: communesAgencyBloc,
          );
        } else {
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

  handleCreateAgency() async {
    String agencyName = agencyNameController.text.trim();
    String agencyAddress = agencyAddressController.text.trim();

    String bossName = agencyBossNameController.text.trim();
    String bossPhone = agencyBossPhoneController.text.trim();
    String bossEmail = agencyBossEmailController.text.trim();
    String bossAddress = agencyBossAddressController.text.trim();

    if (agencyName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập tên đại lý",
        onClickOutSide: () {},
      );
      agencyNameFocusNode.requestFocus();
      return;
    }

    if (provincesAgencyBloc.selectedProvince == null ||
        districtsAgencyBloc.selectedDistrict == null ||
        communesAgencyBloc.selectedCommune == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn địa chỉ đại lý",
        onClickOutSide: () {},
      );
      return;
    }

    if (agencyAddress.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ chi tiết đại lý",
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

    if (provincesUserBloc.selectedProvince == null ||
        districtsUserBloc.selectedDistrict == null ||
        communesUserBloc.selectedCommune == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn địa chỉ chủ đại lý",
        onClickOutSide: () {},
      );
      return;
    }

    if (bossAddress.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ chi tiết chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossAddressFocusNode.requestFocus();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận thêm mới đại lý này?",
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
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          // Add agency

          final agencyAddressField = Address(
            detail: agencyAddress,
            commune: communesAgencyBloc.selectedCommune?.name ?? "",
            district: districtsAgencyBloc.selectedDistrict?.name ?? "",
            province: provincesAgencyBloc.selectedProvince?.name ?? "",
          );


          final agency = Agency(
            generateRandomId(8),
            "",
            agencyName,
            agencyAddressField,
            Timestamp.now(),
            false,
          );

          agency.code = agency.generateAgencyCode(
              fetchAgenciesBloc.getAgenciesOriginal.length + 1);

          // Add agency boss
          String newPassword = "123456";
          String passwordEncrypted = EncryptionHelper.encryptData(
            newPassword,
            dotenv.env["SECRET_KEY_PASSWORD_HASH"]!,
          );


          final bossAddressField = Address(
            province: provincesUserBloc.selectedProvince?.name,
            district: districtsUserBloc.selectedDistrict?.name,
            commune: communesUserBloc.selectedCommune?.name,
            detail: bossAddress,
          );

          // Get text field value
          final user = UserModel(
            id: generateRandomId(8),
            fullName: bossName,
            dob: null,
            email: bossEmail,
            gender: "Male",
            phoneNumber: bossPhone,
            role: Roles.AGENCY_BOSS,
            createdAt: Timestamp.now(),
            address: bossAddressField,
            agency: agency.id,
            password: passwordEncrypted,
            isDelete: false,
          );

          await createAgencyBloc.createAgency(agency: agency, boss: user);
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
            onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
            decoration: InputDecoration(
              border: InputBorder.none, // Remove the underline border
              hintText: widget.isRequired ? "" : widget.hintValue,
              hintStyle: widget.isRequired
                  ? null
                  : AppStyle.bodyText.copyWith(
                      color: const Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
          if (widget.isRequired && widget.controller.text.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
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
