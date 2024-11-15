import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class CustomerBloc extends Cubit<Customer?> {
  CustomerBloc(super.initialState);

  Customer? customer;

  void emitCustomer(Customer customer) {
    this.customer = customer;
    emit(customer);
  }

  void reset(){
    customer = null;
    emit(null);
  }
}