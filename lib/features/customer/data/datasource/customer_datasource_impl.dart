import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource.dart';
import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class CustomerDatasourceImpl extends CustomerDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// Fetch a single customer by phone number.
  @override
  Future<Customer> fetchCustomer(String phoneNumber) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('customers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1) // Limit the result to one document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Customer.fromJson(querySnapshot.docs.first.data());
      } else {
        throw Exception('Customer with phone $phoneNumber not found.');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  /// Fetch all customers from the Firestore collection.
  @override
  Future<List<Customer>> fetchCustomers() async {
    try {
      final querySnapshot =
          await firebaseFirestore.collection('customers').get();
      return querySnapshot.docs
          .map((doc) => Customer.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  /// Search for customers whose phone number matches the query.
  @override
  Future<List<Customer>> searchCustomers(String phoneNumberQuery) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('customers')
          .where('phoneNumber', isGreaterThanOrEqualTo: phoneNumberQuery)
          .where('phoneNumber', isLessThanOrEqualTo: '$phoneNumberQuery\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Customer.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  @override
  Future<List<Guarantee>> fetchGuaranteesOfCustomer(String customerID) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('guarantees')
          .where('customerID', isEqualTo: customerID)
          .get();

      return querySnapshot.docs
          .map((doc) => Guarantee.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to fetch guarantees for customer $customerID: $e');
    }
  }

  @override
  Future<List<Customer>> searchCustomersOfAgency(
      String phoneNumberQuery, String agencyID) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('customers')
          .where("agency", isEqualTo: agencyID)
          .where('phoneNumber', isGreaterThanOrEqualTo: phoneNumberQuery)
          .where('phoneNumber', isLessThanOrEqualTo: '$phoneNumberQuery\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Customer.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  @override
  Future<Customer> fetchCustomerByProductID(String productID) async {
    try {
      // Fetch the guarantee document by product ID
      final guaranteeDocs = await firebaseFirestore
          .collection("guarantees")
          .where("product.id", isEqualTo: productID)
          .limit(1)
          .get();

      // Check if a guarantee document exists
      if (guaranteeDocs.docs.isEmpty) {
        throw Exception("No guarantee found for the given product ID.");
      }

      // Deserialize the guarantee document
      final guarantee = Guarantee.fromJson(guaranteeDocs.docs.first.data());

      // Fetch the customer document using the customer ID from the guarantee
      final customerDocs = await firebaseFirestore
          .collection("customers")
          .where("id", isEqualTo: guarantee.customerID)
          .limit(1)
          .get();

      // Check if a customer document exists
      if (customerDocs.docs.isEmpty) {
        throw Exception("No customer found for the given customer ID.");
      }

      // Deserialize the customer document
      final customer = Customer.fromJson(customerDocs.docs.first.data());

      return customer;
    } catch (e) {
      // Handle any errors appropriately
      print("Error fetching customer by product ID: $e");
      rethrow; // Re-throw the error to allow the caller to handle it
    }
  }

}
