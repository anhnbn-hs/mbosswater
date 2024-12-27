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
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchAllCustomersWithPagination({
    required int limit,
    DocumentSnapshot<Object?>? lastDocument,
    String? provinceFilter,
    String? dateFilter,
    String? searchQuery,
    String? agencyID,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('customers')
        .orderBy('updatedAt', descending: true);

    // Apply province filter
    if (provinceFilter != null && provinceFilter != 'Tất cả') {
      query = query.where('address.province', isEqualTo: provinceFilter);
    }

    // Apply date filter
    if (dateFilter != null && dateFilter != 'Tất cả') {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
      DateTime startDate;

      switch (dateFilter) {
        case 'Tháng này':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case '30 ngày gần đây':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '90 ngày gần đây':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'Năm nay':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = now;
      }

      query = query.where('updatedAt', isGreaterThanOrEqualTo: startDate);
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      String cleanSearch = searchQuery.trim();
      if (RegExp(r'^\d+$').hasMatch(cleanSearch)) {
        query = query
            .where('phoneNumber', isGreaterThanOrEqualTo: cleanSearch)
            .where('phoneNumber', isLessThanOrEqualTo: '$cleanSearch\uf8ff');
      } else {
        String normalizedSearch = Customer.generateSearchTerms(cleanSearch)[0];
        query = query.where('searchTerms', arrayContains: normalizedSearch);
      }
    }

    // Apply agency filter if provided
    if (agencyID != null) {
      query = query.where('agency', isEqualTo: agencyID);
    }

    // Apply limit and pagination
    query = query.limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot querySnapshot = await query.get();

    List<Customer> customers = querySnapshot.docs
        .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    return {
      'customers': customers,
      'lastDocument':
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
    };
  }
}
