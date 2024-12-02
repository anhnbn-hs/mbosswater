import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';

class GuaranteeRepositoryImpl extends GuaranteeRepository {
  final GuaranteeDatasource _datasource;

  GuaranteeRepositoryImpl(this._datasource);

  @override
  Future<void> createGuarantee(
      Guarantee guarantee, Customer customer, ActionType actionType) async {
    return await _datasource.createGuarantee(guarantee, customer, actionType);
  }

  @override
  Future<Customer?> getCustomerExisted(String phoneNumber) async {
    return await _datasource.getCustomerExisted(phoneNumber);
  }

  @override
  Future<Agency> fetchAgency(String agencyID) async {
    return await _datasource.fetchAgency(agencyID);
  }

  @override
  Future<List<Agency>> fetchAgencies() async {
    return await _datasource.fetchAgencies();
  }

  @override
  Future<List<GuaranteeHistory>> fetchGuaranteeHistoryList(
      String guaranteeID) async {
    return await _datasource.fetchGuaranteeHistoryList(guaranteeID);
  }

  @override
  Future<void> createGuaranteeHistory(GuaranteeHistory gHistory) async {
    return await _datasource.createGuaranteeHistory(gHistory);
  }
}
