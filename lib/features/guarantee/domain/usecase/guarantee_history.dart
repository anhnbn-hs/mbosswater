import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';

class GuaranteeHistoryUseCase {
  final GuaranteeRepository _repository;

  GuaranteeHistoryUseCase(this._repository);

  Future<List<GuaranteeHistory>> fetchListGuaranteeHistory(
      String guaranteeID) async {
    return await _repository.fetchGuaranteeHistoryList(guaranteeID);
  }

  Future<void> create(GuaranteeHistory gHistory) async {
    return await _repository.createGuaranteeHistory(gHistory);
  }
}
