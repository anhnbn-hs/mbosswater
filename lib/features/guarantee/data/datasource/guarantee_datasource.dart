import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class GuaranteeDatasource {
  Future<void> createGuarantee(
    Guarantee guarantee,
    Customer customer,
    ActionType actionType,
  );

  Future<Customer?> getCustomerExisted(String phoneNumber);
}
