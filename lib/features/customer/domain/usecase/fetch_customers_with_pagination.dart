import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';

class FetchCustomersWithPaginationUC {
  final CustomerRepository repository;

  FetchCustomersWithPaginationUC(this.repository);

  Future<Map<String, dynamic>> getAll({
    required int limit,
    DocumentSnapshot<Object?>? lastDocument,
    String? provinceFilter,
    String? dateFilter,
    String? searchQuery,
    String? agencyID,
  }) async {
    return await repository.fetchAllCustomersWithPagination(
      limit: limit,
      lastDocument: lastDocument,
      searchQuery: searchQuery,
      agencyID: agencyID,
      dateFilter: dateFilter,
      provinceFilter: provinceFilter,
    );
  }
}
