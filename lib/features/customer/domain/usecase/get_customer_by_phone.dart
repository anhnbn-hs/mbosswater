import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class GetCustomerByPhoneUseCase {
  final CustomerRepository repository;

  GetCustomerByPhoneUseCase(this.repository);

  Future<Customer> call(String phoneNumber) async {
    return await repository.fetchCustomer(phoneNumber);
  }
}
