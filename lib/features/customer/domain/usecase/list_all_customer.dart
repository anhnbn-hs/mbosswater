import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class ListAllCustomerUseCase {
  final CustomerRepository repository;

  ListAllCustomerUseCase(this.repository);

  Future<List<CustomerEntity>> call() async {
    return await repository.fetchCustomersEntity();
  }
}