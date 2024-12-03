import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_by_phone.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_by_product.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_state.dart';

class FetchCustomerBloc extends Bloc<FetchCustomerEvent, FetchCustomerState> {
  final GetCustomerByProductUseCase getCustomerByProductUseCase;
  final GetCustomerByPhoneUseCase getCustomerByPhoneUseCase;

  FetchCustomerBloc(
      this.getCustomerByProductUseCase, this.getCustomerByPhoneUseCase)
      : super(FetchCustomerInitial()) {
    on<FetchCustomerByProduct>(
      (event, emit) async {
        try {
          emit(FetchCustomerLoading());
          final customer = await getCustomerByProductUseCase(event.productID);
          emit(FetchCustomerSuccess(customer));
        } on Exception catch (e) {
          emit(FetchCustomerError(e.toString()));
        }
      },
    );

    on<FetchCustomerByPhoneNumber>(
      (event, emit) async {
        try {
          emit(FetchCustomerLoading());
          final customer = await getCustomerByPhoneUseCase(event.phoneNumber);
          emit(FetchCustomerSuccess(customer));
        } on Exception catch (e) {
          emit(FetchCustomerError(e.toString()));
        }
      },
    );
  }

  void reset() {
    emit(FetchCustomerInitial());
  }
}
