import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class GuaranteeDatasource {
  Future<void> createGuarantee(Guarantee guarantee, Customer customer);
}
