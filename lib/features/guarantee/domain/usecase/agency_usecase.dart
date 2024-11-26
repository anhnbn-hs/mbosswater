import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';

class AgencyUseCase {
  final GuaranteeRepository _repository;

  AgencyUseCase(this._repository);

  Future<Agency> getAgency(String agencyID) async {
    return await _repository.fetchAgency(agencyID);
  }

  Future<List<Agency>> getAgencies() async {
    return await _repository.fetchAgencies();
  }
}