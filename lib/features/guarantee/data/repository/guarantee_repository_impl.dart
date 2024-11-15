import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';

class GuaranteeRepositoryImpl extends GuaranteeRepository {
  final GuaranteeDatasource _datasource;

  GuaranteeRepositoryImpl(this._datasource);

  @override
  Future<void> createGuarantee(Guarantee guarantee, Customer customer) async {
    return await _datasource.createGuarantee(guarantee, customer);
  }
}
