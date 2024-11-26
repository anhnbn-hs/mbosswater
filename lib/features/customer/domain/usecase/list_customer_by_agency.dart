import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class ListCustomerByAgencyUseCase {
  final CustomerRepository repository;

  ListCustomerByAgencyUseCase(this.repository);

  Future<List<CustomerEntity>> call(String agencyID) async {
    return await repository.fetchCustomersOfAgency(agencyID);
  }
}