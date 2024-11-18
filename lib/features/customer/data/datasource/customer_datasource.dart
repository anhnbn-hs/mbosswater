import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class CustomerDatasource {
  Future<Customer> fetchCustomer(String phoneNumber);

  Future<List<Customer>> fetchCustomers();

  Future<List<Customer>> searchCustomers(String phoneNumberQuery);

  Future<List<Guarantee>> fetchGuaranteesOfCustomer(String customerID);
}
