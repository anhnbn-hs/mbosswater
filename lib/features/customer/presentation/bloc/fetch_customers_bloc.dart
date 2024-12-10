import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/list_all_customer.dart';
import 'package:mbosswater/features/customer/domain/usecase/list_customer_by_agency.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_state.dart';

class FetchCustomersBloc
    extends Bloc<FetchCustomersEvent, FetchCustomersState> {
  final ListCustomerByAgencyUseCase listCustomerByAgencyUseCase;
  final ListAllCustomerUseCase listAllCustomerUseCase;

  FetchCustomersBloc(
      this.listCustomerByAgencyUseCase, this.listAllCustomerUseCase)
      : super(FetchCustomersInitial()) {
    on<FetchAllCustomers>(_fetchAllCustomer);
    on<FetchAllCustomersByAgency>(_fetchAllCustomersByAgency);
    on<SearchCustomers>(_searchCustomers);
  }

  FutureOr<void> _fetchAllCustomer(
      FetchAllCustomers event, Emitter<FetchCustomersState> emit) async {
    try {
      emit(FetchCustomersLoading());
      final customers = await listAllCustomerUseCase();
      emit(FetchCustomersSuccess(customers, customers));
    } on Exception catch (e) {
      emit(FetchCustomersError(e.toString()));
    }
  }

  FutureOr<void> _fetchAllCustomersByAgency(FetchAllCustomersByAgency event,
      Emitter<FetchCustomersState> emit) async {
    try {
      emit(FetchCustomersLoading());
      final customers = await listCustomerByAgencyUseCase(event.agency);
      emit(FetchCustomersSuccess(customers, customers));
    } on Exception catch (e) {
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
              currentState.originalCustomers,
              currentState
                  .filteredCustomers));
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
