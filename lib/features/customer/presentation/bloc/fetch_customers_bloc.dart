import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/domain/usecase/list_customer_by_agency.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_state.dart';

class FetchCustomersBloc
    extends Bloc<FetchCustomersEvent, FetchCustomersState> {
  final ListCustomerByAgencyUseCase listCustomerByAgencyUseCase;

  FetchCustomersBloc(this.listCustomerByAgencyUseCase)
      : super(FetchCustomersInitial()) {
    on<FetchAllCustomersByAgency>(_fetchAllCustomersByAgency);
    on<SearchCustomers>(_searchCustomers);
  }

  FutureOr<void> _fetchAllCustomersByAgency(FetchAllCustomersByAgency event,
      Emitter<FetchCustomersState> emit) async {
    try {
      emit(FetchCustomersLoading());
      final customers = await listCustomerByAgencyUseCase(event.agency);
      emit(FetchCustomersAgencySuccess(customers, customers));
    } on Exception catch (e) {
      emit(FetchCustomersError(e.toString()));
    }
  }

  FutureOr<void> _searchCustomers(
      SearchCustomers event, Emitter<FetchCustomersState> emit) async {
    // Lấy trạng thái hiện tại
    final currentState = state;

    if (currentState is FetchCustomersAgencySuccess) {
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
