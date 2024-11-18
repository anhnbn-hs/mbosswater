import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource.dart';
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
      final querySnapshot = await firebaseFirestore.collection('customers').get();
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
      throw Exception('Failed to fetch guarantees for customer $customerID: $e');
    }
  }
}
