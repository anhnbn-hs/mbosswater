import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';

class ActiveGuaranteeUseCase {
  final GuaranteeRepository _repository;

  ActiveGuaranteeUseCase(this._repository);

  Future<void> call(Guarantee guarantee, Customer customer) async {
    return await _repository.createGuarantee(guarantee, customer);
  }
}
