import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/features/agency/presentation/page/agency_staff_management.dart';
import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_state.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
import 'package:mbosswater/features/customer/presentation/widgets/filter_dropdown_agency.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agencies_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late FetchCustomersBloc fetchCustomersBloc;
  late UserInfoBloc userInfoBloc;
  late AgenciesBloc agenciesBloc;

  final List<String> dropdownTimeItems = [
    'Tất cả',
    'Tháng này',
    '30 ngày gần đây',
    '90 ngày gần đây',
    'Năm nay'
  ];

  List<Agency> dropdownAgenciesItems = [];
  ValueNotifier<String?> searchNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedTimeFilter = ValueNotifier(null);
  ValueNotifier<Agency?> selectedAgencyFilter = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();

  // Variable
  List<CustomerEntity> customerSearchResult = [];
  List<CustomerEntity> customerOriginal = [];
  ValueNotifier<int> totalCustomer = ValueNotifier(0);
  ValueNotifier<int> totalProductSold = ValueNotifier(0);

  final GlobalKey _sliverAppBarContentKey = GlobalKey();
  double _sliverAppBarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    fetchCustomersBloc = BlocProvider.of<FetchCustomersBloc>(context);
    agenciesBloc = BlocProvider.of<AgenciesBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    handleFetchCustomer();
    if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN) {
      agenciesBloc.fetchAgencies();
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

  handleFetchCustomer() {
    final user = userInfoBloc.user;
    bool isAgency = Roles.LIST_ROLES_AGENCY.contains(user?.role);
    if (isAgency && user?.agency != null) {
      fetchCustomersBloc.add(FetchAllCustomersByAgency(user!.agency!));
    } else {
      // Fetch all customer (for MBoss)
      fetchCustomersBloc.add(FetchAllCustomers());
    }
  }

  Widget buildSliverAppBarContent() {
    return Column(
      key: _sliverAppBarContentKey,
      children: [
        // Nội dung trong SliverAppBarContent
        buildHeaderSection(),
        Divider(
          color: Colors.grey.shade400,
          height: 36,
          thickness: .4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 3),
                alignment: Alignment.centerLeft,
                child: FilterDropdown(
                  selectedValue: selectedTimeFilter.value ?? 'Tất cả',
                  onChanged: (value) {
                    setState(() {
                      selectedTimeFilter.value = value;
                    });
                  },
                  options: dropdownTimeItems,
                ),
              ),
              if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN)
                Container(
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder(
                    bloc: agenciesBloc,
                    builder: (context, state) {
                      if (state is AgenciesLoaded) {
                        dropdownAgenciesItems.clear();
                        dropdownAgenciesItems = List.from(state.agencies);
                        dropdownAgenciesItems.insert(
                          0,
                          Agency(
                            "",
                            "",
                            "Tất cả",
                            null,
                            Timestamp.now(),
                            false,
                          ),
                        );
                        return FilterDropdownAgency(
                          onChanged: (value) {
                            setState(() {
                              selectedAgencyFilter.value = value;
                            });
                          },
                          options: dropdownAgenciesItems,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: totalCustomer,
                builder: (context, value, child) {
                  return buildInfoItem(
                    label: "Tổng khách hàng",
                    value: value.toString(),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: totalProductSold,
                builder: (context, value, child) {
                  return buildInfoItem(
                    label: "Tổng sản phẩm đã bán",
                    value: totalProductSold.value.toString(),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
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
                        padding: const EdgeInsets.only(left: 6, right: 16),
                        child: Stack(
                          children: [
                            Container(
                              height: kToolbarHeight - 4,
                              padding: const EdgeInsets.only(left: 16),
                              alignment: Alignment.center,
                              child: Text(
                                "Danh Sách Khách Hàng",
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
          body: BlocBuilder(
            bloc: fetchCustomersBloc,
            builder: (context, state) {
              if (state is FetchCustomersLoading) {
                return ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: const CustomerCardShimmer(),
                  ),
                );
              }
              if (state is FetchCustomersSuccess) {
                customerSearchResult = state.filteredCustomers;
                customerOriginal = state.originalCustomers;

                return buildCustomerList();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget buildInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const SizedBox(width: 36),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "BeVietnam",
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

  Padding buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            height: 40,
            width: double.infinity,
            alignment: FractionalOffset.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xffEEEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SearchField(
              hint: "Tìm kiếm theo tên hoặc số điện thoại",
              onSearch: (value) {
                setState(() {
                  searchNotifier.value = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerList() {
    // Perform filtering outside the build process
    customerSearchResult = customerOriginal.where((customer) {
      // 1. Filter by search
      final matchesSearch = searchNotifier.value == null ||
          customer.customer.fullName!
              .toLowerCase()
              .contains(searchNotifier.value!.toLowerCase()) ||
          customer.customer.phoneNumber!
              .toLowerCase()
              .contains(searchNotifier.value!.toLowerCase()) ||
          customer.customer.address!
              .displayAddress()
              .toLowerCase()
              .contains(searchNotifier.value!.toLowerCase());

      // 2. Filter by agency
      final matchesAgency = selectedAgencyFilter.value == null ||
          selectedAgencyFilter.value?.id == "" || // "Tất cả"
          customer.customer.agency == selectedAgencyFilter.value?.id;

      // 3. Filter by time
      final matchesTime = () {
        if (selectedTimeFilter.value == null ||
            selectedTimeFilter.value == "Tất cả") return true;
        DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
        DateTime? updatedAt = customer.customer.updatedAt?.toDate();

        switch (selectedTimeFilter.value) {
          case "Tháng này":
            return updatedAt?.year == now.year && updatedAt?.month == now.month;
          case "30 ngày gần đây":
            return updatedAt != null &&
                updatedAt.isAfter(now.subtract(const Duration(days: 30)));
          case "90 ngày gần đây":
            return updatedAt != null &&
                updatedAt.isAfter(now.subtract(const Duration(days: 90)));
          case "Năm nay":
            return updatedAt?.year == now.year;
          default:
            return true;
        }
      }();

      // Combine all filters
      return matchesSearch && matchesAgency && matchesTime;
    }).toList();

    // Update stats outside build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      totalCustomer.value = customerSearchResult.length;
      totalProductSold.value = customerSearchResult.fold(
          0, (sum, customer) => sum + customer.guarantees.length);
    });

    if (customerSearchResult.isEmpty) {
      return const Center(
        child: Text("Không tìm thấy khách hàng!"),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        itemCount: customerSearchResult.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomerCardItem(
              customerEntity: customerSearchResult[index],
            ),
          );
        },
      ),
    );
  }
}

