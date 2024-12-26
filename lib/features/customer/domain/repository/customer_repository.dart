import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class CustomerRepository {
  // MBoss
  Future<Customer> fetchCustomer(String phoneNumber);

  Future<Map<String, dynamic>> fetchAllCustomersWithPagination({
    required int limit,
    DocumentSnapshot<Object?>? lastDocument,
    String? provinceFilter,
    String? dateFilter,
    String? searchQuery,
    String? agencyID,
  });

  Future<List<Customer>> fetchCustomers();

  Future<List<Customer>> searchCustomers(String phoneNumberQuery);

  // Agency
  Future<List<Customer>> searchCustomersOfAgency(
      String phoneNumberQuery, String agencyID);

  Future<List<Guarantee>> fetchGuaranteesOfCustomer(String customerID);

  Future<Customer> fetchCustomerByProductID(String productID);
}
