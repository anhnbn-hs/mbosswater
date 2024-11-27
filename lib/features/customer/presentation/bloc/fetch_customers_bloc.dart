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
}
