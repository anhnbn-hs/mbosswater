import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/fetch_customers_with_pagination.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_event.dart';
import 'fetch_customers_paginate_state.dart';

class FetchCustomersPaginateBloc
    extends Bloc<FetchCustomersPaginateEvent, FetchCustomersPaginateState> {
  final FetchCustomersWithPaginationUC fetchCustomersWithPaginationUC;

  FetchCustomersPaginateBloc(this.fetchCustomersWithPaginationUC)
      : super(FetchCustomersInitial()) {
    on<FetchCustomers>(_fetchCustomers);
    on<FetchNextPage>(_fetchNextPage);
  }

  // Handle FetchCustomers event
  Future<void> _fetchCustomers(
      FetchCustomers event, Emitter<FetchCustomersPaginateState> emit) async {
    emit(FetchCustomersLoading());
    try {
      final result = await fetchCustomersWithPaginationUC.getAll(
        limit: event.limit,
        provinceFilter: event.provinceFilter,
        dateFilter: event.dateFilter,
        searchQuery: event.searchQuery,
        agencyID: event.agencyID,
      );

      final customers = result['customers'];
      final lastDocument = result['lastDocument'];
      final hasMore = customers.length >= event.limit;

      emit(FetchCustomersLoaded(
        customers: customers,
        hasMore: hasMore,
        lastDocument: lastDocument,
      ));
    } catch (e) {
      emit(FetchCustomersError(message: e.toString()));
    }
  }

  // Handle FetchNextPage event
  Future<void> _fetchNextPage(
      FetchNextPage event,
      Emitter<FetchCustomersPaginateState> emit,
      ) async {
    if (state is FetchCustomersLoaded) {
      final currentState = state as FetchCustomersLoaded;

      if (!currentState.hasMore || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final result = await fetchCustomersWithPaginationUC.getAll(
          limit: event.limit,
          lastDocument: currentState.lastDocument,
        );

        final newCustomers = result['customers'];
        final newLastDocument = result['lastDocument'];
        final hasMore = newCustomers.length >= event.limit;

        emit(FetchCustomersLoaded(
          customers: [...currentState.customers, ...newCustomers],
          hasMore: hasMore,
          isLoadingMore: false,
          lastDocument: newLastDocument,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(FetchCustomersError(message: e.toString()));
      }
    }
  }
}
