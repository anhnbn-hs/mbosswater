import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class GuaranteeRepository {
  Future<void> createGuarantee(Guarantee guarantee, Customer customer);
}