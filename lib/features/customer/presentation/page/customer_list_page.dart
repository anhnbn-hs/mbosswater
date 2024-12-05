import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_state.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late FetchCustomersBloc fetchCustomersBloc;
  late UserInfoBloc userInfoBloc;

  @override
  void initState() {
    super.initState();
    fetchCustomersBloc = BlocProvider.of<FetchCustomersBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    handleFetchCustomer();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeaderSection(),
            Divider(
              color: Colors.grey.shade400,
              height: 40,
              thickness: .2,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: AlignmentDirectional.centerStart,
              child: FilterDropdown(
                selectedValue: 'Tháng',
                onChanged: (value) {},
                options: const ["Tháng", "Tháng này", "6 ngày trước"],
              ),
            ),
            BlocBuilder<FetchCustomersBloc, FetchCustomersState>(
              bloc: fetchCustomersBloc,
              builder: (context, state) {
                var customers = [];
                int totalProductSold = 0;
                if (state is FetchCustomersSuccess) {
                  customers = state.filteredCustomers;
                  totalProductSold = state.filteredCustomers.fold(
                    0,
                    (sum, c) => sum + c.guarantees.length,
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      buildInfoItem(
                        label: "Tổng khách hàng",
                        value: customers.length.toString(),
                      ),
                      buildInfoItem(
                        label: "Tổng sản phẩm đã bán",
                        value: totalProductSold.toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            buildListViewCustomer(),
          ],
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
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Danh Sách Khách Hàng",
              style: TextStyle(
                fontFamily: "BeVietnam",
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
              onSearch: (value) => fetchCustomersBloc.add(
                SearchCustomers(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListViewCustomer() {
    return BlocBuilder(
      bloc: fetchCustomersBloc,
      builder: (context, state) {
        if (state is FetchCustomersLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 70),
          );
        }
        if (state is FetchCustomersSuccess) {
          final listCustomer = state.filteredCustomers;

          if (listCustomer.isEmpty) {
            return const Center(
              child: Text("Không tìm thấy khách hàng!"),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            margin: const EdgeInsets.only(bottom: 20),
            child: ListView.builder(
              itemCount: listCustomer.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomerCardItem(
                    customerEntity: listCustomer[index],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

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
          hintText: 'Tìm kiếm khách hàng',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'BeVietNam',
            color: Colors.grey.shade500,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10)),
    );
  }
}


