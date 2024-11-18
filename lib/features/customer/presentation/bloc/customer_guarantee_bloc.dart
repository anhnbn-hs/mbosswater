import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_guarantee.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_state.dart';

class CustomerGuaranteeBloc
    extends Bloc<CustomerGuaranteeEvent, CustomerGuaranteeState> {
  final GetCustomerGuaranteeUseCase useCase;

  CustomerGuaranteeBloc(this.useCase) : super(CustomerGuaranteeInitial()) {
    on<FetchCustomerGuarantees>(
      (event, emit) async {
        emit(CustomerGuaranteeLoading());
        try {
          final guarantees = await useCase.call(event.customerID);
          emit(CustomerGuaranteeLoaded(guarantees));
        } catch (e) {
          emit(CustomerGuaranteeError('Failed to fetch guarantees: $e'));
        }
      },
    );
  }
}
