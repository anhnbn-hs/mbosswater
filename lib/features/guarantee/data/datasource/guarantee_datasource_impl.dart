import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class GuaranteeDatasourceImpl extends GuaranteeDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<void> createGuarantee(Guarantee guarantee, Customer customer) async {
    final WriteBatch batch = _firebaseFirestore.batch();

    try {
      final customerRef =
          _firebaseFirestore.collection('customers').doc(customer.id);
      batch.set(customerRef, customer.toJson());

      final guaranteeRef =
          _firebaseFirestore.collection('guarantees').doc(guarantee.id);
      batch.set(guaranteeRef, guarantee.toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create guarantee and customer: $e');
    }
  }
}
