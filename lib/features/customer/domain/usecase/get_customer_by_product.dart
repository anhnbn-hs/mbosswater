import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class GetCustomerByProductUseCase {
  final CustomerRepository repository;

  GetCustomerByProductUseCase(this.repository);

  Future<Customer> call(String productID) async {
    return await repository.fetchCustomerByProductID(productID);
  }
}