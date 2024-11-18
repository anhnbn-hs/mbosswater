import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class GetCustomerGuaranteeUseCase {
  final CustomerRepository repository;

  GetCustomerGuaranteeUseCase(this.repository);

  Future<List<Guarantee>> call(String customerID) async {
    return await repository.fetchGuaranteesOfCustomer(customerID);
  }
}