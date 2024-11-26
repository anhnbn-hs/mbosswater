import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class SearchCustomerUseCase {
  final CustomerRepository repository;

  SearchCustomerUseCase(this.repository);

  Future<List<Customer>> searchAll(String phoneNumberQuery) async {
    return await repository.searchCustomers(phoneNumberQuery);
  }

  Future<List<Customer>> searchByAgency(
      String phoneNumberQuery, String agencyID) async {
    return await repository.searchCustomersOfAgency(phoneNumberQuery, agencyID);
  }
}
