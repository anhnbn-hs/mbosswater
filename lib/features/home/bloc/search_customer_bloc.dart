import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/search_customer.dart';
import 'package:mbosswater/features/home/bloc/search_customer_event.dart';
import 'package:mbosswater/features/home/bloc/search_customer_state.dart';

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  final SearchCustomerUseCase searchCustomerUseCase;

  CustomerSearchBloc(this.searchCustomerUseCase)
      : super(CustomerSearchInitial()) {
    on<SearchAllCustomersByPhone>(_onSearchAllCustomers);
    on<SearchAgencyCustomersByPhone>(_onSearchAgencyCustomers);
  }

  Future<void> _onSearchAllCustomers(
    SearchAllCustomersByPhone event,
    Emitter<CustomerSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(CustomerSearchLoaded([]));
      return;
    }
    emit(CustomerSearchLoading());

    try {
      // Replace this with your actual API call
      final customers = await searchCustomerUseCase.searchAll(event.query);
      emit(CustomerSearchLoaded(customers));
    } catch (e) {
      emit(CustomerSearchError('Error searching customers: $e'));
    }
  }

  Future<void> _onSearchAgencyCustomers(
    SearchAgencyCustomersByPhone event,
    Emitter<CustomerSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(CustomerSearchLoaded([]));
      return;
    }

    emit(CustomerSearchLoading());

    try {
      // Replace this with your actual API call
      final customers = await searchCustomerUseCase.searchByAgency(
          event.query, event.agencyID);
      emit(CustomerSearchLoaded(customers));
    } catch (e) {
      emit(CustomerSearchError('Error searching customers: $e'));
    }
  }
}
