import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/search_customer.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_state.dart';

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  final SearchCustomerUseCase searchCustomerUseCase;

  CustomerSearchBloc(this.searchCustomerUseCase)
      : super(CustomerSearchInitial()) {
    on<SearchCustomersByPhone>(_onSearchCustomers);
  }

  Future<void> _onSearchCustomers(
    SearchCustomersByPhone event,
    Emitter<CustomerSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(CustomerSearchLoaded([]));
      return;
    }
    emit(CustomerSearchLoading());

    try {
      // Replace this with your actual API call
      final customers = await searchCustomerUseCase(event.query);
      emit(CustomerSearchLoaded(customers));
    } catch (e) {
      emit(CustomerSearchError('Error searching customers: $e'));
    }
  }
}
