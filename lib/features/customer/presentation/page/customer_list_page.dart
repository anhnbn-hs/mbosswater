import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/features/agency/presentation/page/agency_staff_management.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_state.dart';
import 'package:mbosswater/features/customer/presentation/bloc/provinces_metadata_bloc.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _pageSize = 10;

  final _searchController = TextEditingController();

  late FetchCustomersPaginateBloc fetchCustomersBloc;
  late UserInfoBloc userInfoBloc;
  late final ProvincesMetadataBloc provincesBloc;
  final List<String> dropdownTimeItems = [
    'Tất cả',
    'Tháng này',
    '30 ngày gần đây',
    '90 ngày gần đây',
    'Năm nay'
  ];

  ValueNotifier<String?> searchNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedTimeFilter = ValueNotifier(null);
  late ValueNotifier<String?> selectedProvinceFilter = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();

  // Variable
  ValueNotifier<int> totalCustomer = ValueNotifier(0);
  ValueNotifier<int> totalProductSold = ValueNotifier(0);

  final GlobalKey _sliverAppBarContentKey = GlobalKey();
  double _sliverAppBarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    fetchCustomersBloc = BlocProvider.of<FetchCustomersPaginateBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    provincesBloc = BlocProvider.of<ProvincesMetadataBloc>(context);
    handleFetchCustomer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSliverAppBarHeight();
    });
    // Add scroll listener for infinite pagination
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_shouldLoadMore(_scrollController)) {
        // fetchCustomersBloc.add(FetchNextPage(_pageSize));
      }
    });
  }

  bool _shouldLoadMore(ScrollController scrollController) {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Lottie.asset(AppAssets.aLoading, height: 50),
      ),
    );
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

  handleFetchCustomer() {
    final user = userInfoBloc.user;
    bool isAgency = Roles.LIST_ROLES_AGENCY.contains(user?.role);
    if (isAgency && user?.agency != null) {
      fetchCustomersBloc.add(FetchCustomers(
        limit: _pageSize,
        agencyID: user?.agency,
      ));
    } else {
      // Fetch all customer (for MBoss)
      fetchCustomersBloc.add(FetchCustomers(limit: _pageSize));
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
                child: ValueListenableBuilder(
                  valueListenable: selectedTimeFilter,
                  builder: (context, value, child) => FilterDropdown(
                    selectedValue: selectedTimeFilter.value ?? 'Tất cả',
                    onChanged: (value) {
                      selectedTimeFilter.value = value;
                      fetchCustomersBloc.add(FetchCustomers(
                        limit: _pageSize,
                        searchQuery: _searchController.text != ""
                            ? _searchController.text
                            : null,
                        provinceFilter: selectedProvinceFilter.value,
                        dateFilter: selectedTimeFilter.value,
                        agencyID: userInfoBloc.user?.agency,
                      ));
                    },
                    options: dropdownTimeItems,
                  ),
                ),
              ),
              if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN)
                buildFilterProvince(),
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

  Widget buildFilterProvince() {
    return GestureDetector(
      onTap: () async => showBottomSheetChooseProvinces(),
      child: Container(
        height: 29,
        width: MediaQuery.of(context).size.width / 2 - 24 - 3,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffEFEFF0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ValueListenableBuilder(
                  valueListenable: selectedProvinceFilter,
                  builder: (context, value, child) => Text(
                    value ?? "Tỉnh/Thành phố",
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: "BeVietnam",
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  showBottomSheetChooseProvinces() async {
    final size = MediaQuery.of(context).size;
    provincesBloc.add(FetchProvincesMetaData());
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: size.height * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chọn tỉnh thành",
                  style: AppStyle.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffEEEEEE),
                  ),
                  child: Center(
                    child: TextField(
                      style: AppStyle.boxField.copyWith(fontSize: 15),
                      onChanged: (value) {
                        provincesBloc.add(SearchProvincesMetaData(value));
                      },
                      textAlignVertical: TextAlignVertical.center,
                      onTapOutside: (event) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm tỉnh thành",
                        hintStyle: AppStyle.boxField.copyWith(fontSize: 15),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        isCollapsed: true,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder(
                    bloc: provincesBloc,
                    builder: (context, state) {
                      if (state is ProvincesMetaDataLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 50),
                        );
                      }
                      if (state is ProvincesMetaDataLoaded) {
                        final provinces = List<String>.from(state.provinces);
                        provinces.insert(0, "Tất cả");
                        return ListView.builder(
                          itemCount: provinces.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: .2,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  selectedProvinceFilter.value =
                                      provinces[index];

                                  fetchCustomersBloc.add(FetchCustomers(
                                    limit: _pageSize,
                                    searchQuery: _searchController.text != ""
                                        ? _searchController.text
                                        : null,
                                    provinceFilter:
                                        selectedProvinceFilter.value,
                                    dateFilter: selectedTimeFilter.value,
                                    agencyID: userInfoBloc.user?.agency,
                                  ));

                                  context.pop();
                                },
                                leading: null,
                                minTileHeight: 48,
                                titleAlignment: ListTileTitleAlignment.center,
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(
                                  provinces[index],
                                  style: AppStyle.boxField.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    provincesBloc.emitProvincesFullList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    selectedProvinceFilter.dispose();
    _searchController.dispose();
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
          body: BlocConsumer(
            bloc: fetchCustomersBloc,
            listener: (context, state) {
              if (state is FetchCustomersLoaded) {
                if (state.customers.isEmpty) {
                  totalCustomer.value = 0;
                  totalProductSold.value = 0;
                } else {
                  totalCustomer.value = state.customers.length;
                  totalProductSold.value = state.customers.fold(
                    0,
                    (sum, customer) => sum += customer.totalProduct ?? 0,
                  );
                }
              }
            },
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
              if (state is FetchCustomersLoaded) {
                return buildCustomerList(
                  state.customers,
                  state.hasMore,
                  state.isLoadingMore,
                );
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
              controller: _searchController,
              hint: "Tìm kiếm theo tên hoặc số điện thoại",
              onSearch: (value) {
                fetchCustomersBloc.add(FetchCustomers(
                  limit: _pageSize,
                  searchQuery: value,
                  provinceFilter: selectedProvinceFilter.value,
                  dateFilter: selectedTimeFilter.value,
                  agencyID: userInfoBloc.user?.agency,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerList(
    List<Customer> customers,
    bool hasMore,
    bool isLoadingMore,
  ) {
    return ListView.builder(
      itemCount: customers.length + (hasMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemBuilder: (context, index) {
        if (index >= customers.length) {
          fetchCustomersBloc.add(FetchNextPage(_pageSize));
          return _buildLoadingIndicator();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CustomerCardItem(customer: customers[index]),
        );
      },
    );
  }
}
