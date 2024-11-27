import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class CustomerRepository {
  // MBoss
  Future<Customer> fetchCustomer(String phoneNumber);

  Future<List<CustomerEntity>> fetchCustomersEntity();

  Future<List<Customer>> fetchCustomers();

  Future<List<Customer>> searchCustomers(String phoneNumberQuery);

  // Agency
  Future<List<CustomerEntity>> fetchCustomersOfAgency(String agencyID);

  Future<List<Customer>> searchCustomersOfAgency(
      String phoneNumberQuery, String agencyID);

  Future<List<Guarantee>> fetchGuaranteesOfCustomer(String customerID);
  Future<Customer> fetchCustomerByProductID(String productID);
}
