import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:rxdart/rxdart.dart';

class FetchCustomersBloc
    extends Bloc<FetchCustomersEvent, FetchCustomersState> {
  // Cache stream
  final BehaviorSubject<List<CustomerEntity>> _cachedCustomersStream =
      BehaviorSubject<List<CustomerEntity>>();
  final BehaviorSubject<List<CustomerEntity>> _cachedCustomersAgencyStream =
      BehaviorSubject<List<CustomerEntity>>();

  bool _isDataFetched = false;
  bool _isDataForAgencyFetched = false;

  FetchCustomersBloc() : super(FetchCustomersInitial()) {
    on<FetchAllCustomers>(_fetchAllCustomer);
    on<FetchAllCustomersByAgency>(_fetchAllCustomersByAgency);
    on<SearchCustomers>(_searchCustomers);
  }

  FutureOr<void> _fetchAllCustomer(
      FetchAllCustomers event, Emitter<FetchCustomersState> emit) async {
    try {
      emit(FetchCustomersLoading());

      if (_isDataFetched) {
        emit(FetchCustomersSuccess(
            _cachedCustomersStream.value, _cachedCustomersStream.value));
        return;
      }

      final customersStream =
          FirebaseFirestore.instance.collection('customers')
              .orderBy("updatedAt", descending: true)
              .snapshots();

      await for (var snapshot in customersStream) {
        List<CustomerEntity> customerEntities = [];

        for (var doc in snapshot.docs) {
          final customer = Customer.fromJson(doc.data());
          final guaranteesQuery = await FirebaseFirestore.instance
              .collection('guarantees')
              .where("customerID", isEqualTo: customer.id)
              .orderBy("createdAt", descending: true)
              .get();

          List<Guarantee> guarantees = guaranteesQuery.docs
              .map((doc) => Guarantee.fromJson(doc.data()))
              .toList();

          customerEntities.add(CustomerEntity(customer, guarantees));
        }

        // Cập nhật vào cache
        _cachedCustomersStream.add(customerEntities);
        _isDataFetched = true;

        // Emit dữ liệu sau khi nhận và cache dữ liệu
        emit(FetchCustomersSuccess(customerEntities, customerEntities));
      }
    } catch (e) {
      emit(FetchCustomersError(e.toString()));
    }
  }

  FutureOr<void> _fetchAllCustomersByAgency(FetchAllCustomersByAgency event,
      Emitter<FetchCustomersState> emit) async {
    try {
      emit(FetchCustomersLoading());

      if (_isDataForAgencyFetched) {
        emit(FetchCustomersSuccess(_cachedCustomersAgencyStream.value,
            _cachedCustomersAgencyStream.value));
        return;
      }

      final customersStream = FirebaseFirestore.instance
          .collection('customers')
          .where("agency", isEqualTo: event.agency)
          .snapshots();

      await for (var snapshot in customersStream) {
        List<CustomerEntity> customerEntities = [];

        for (var doc in snapshot.docs) {
          final customer = Customer.fromJson(doc.data());
          final guaranteesQuery = await FirebaseFirestore.instance
              .collection('guarantees')
              .where("customerID", isEqualTo: customer.id)
              .get();

          List<Guarantee> guarantees = guaranteesQuery.docs
              .map((doc) => Guarantee.fromJson(doc.data()))
              .toList();

          customerEntities.add(CustomerEntity(customer, guarantees));
        }

        // Cập nhật vào cache
        _cachedCustomersAgencyStream.add(customerEntities);
        _isDataForAgencyFetched = true;

        // Emit dữ liệu sau khi nhận và cache dữ liệu
        emit(FetchCustomersSuccess(customerEntities, customerEntities));
      }
    } catch (e) {
      emit(FetchCustomersError(e.toString()));
    }
  }

  FutureOr<void> _searchCustomers(
      SearchCustomers event, Emitter<FetchCustomersState> emit) async {
    // Lấy trạng thái hiện tại
    final currentState = state;

    if (currentState is FetchCustomersSuccess) {
      emit(FetchCustomersLoading());
      // Lọc khách hàng dựa trên query
      final query = event.query.toLowerCase();
      final filtered = currentState.originalCustomers.where((c) {
        return c.customer.phoneNumber!.contains(query) ||
            c.customer.fullName!.toLowerCase().contains(query);
      }).toList();
      await Future.delayed(const Duration(milliseconds: 500));
      // Cập nhật state với danh sách đã lọc
      emit(currentState.copyWith(filteredCustomers: filtered));
    }
  }

  void filterCustomer(String filterValue) {
    final currentState = state;
    if (currentState is FetchCustomersSuccess) {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
      DateTime? startDate;
      switch (filterValue) {
        case "Tháng này":
          // Lấy ngày đầu tiên của tháng hiện tại
          startDate = DateTime(now.year, now.month, 1);

          break;

        case "30 ngày gần đây":
          startDate = now.subtract(const Duration(days: 30));
          break;

        case "90 ngày gần đây":
          startDate = now.subtract(const Duration(days: 90));
          break;

        case "Năm nay":
          startDate = DateTime(now.year, 1, 1);
          break;

        default:
          print("Invalid filter value: $filterValue");
          emit(FetchCustomersSuccess(
              currentState.originalCustomers, currentState.filteredCustomers));
          return; // Exit the function
      }

      final filteredCustomers = currentState.originalCustomers.where((c) {
        final hasValidGuarantee = c.guarantees.any((guarantee) {
          return guarantee.createdAt.toDate().isAfter(startDate!);
        });
        return hasValidGuarantee;
      }).toList();

      emit(currentState.copyWith(filteredCustomers: filteredCustomers));
    }
  }
}
