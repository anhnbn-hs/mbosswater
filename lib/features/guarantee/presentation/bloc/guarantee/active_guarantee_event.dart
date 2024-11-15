import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class ActiveGuaranteeEvent {}

class ActiveGuarantee extends ActiveGuaranteeEvent {
  final Guarantee guarantee;
  final Customer customer;

  ActiveGuarantee(this.guarantee, this.customer);
}

class RemoveActiveGuarantee extends ActiveGuaranteeEvent {
  final String guaranteeId;

  RemoveActiveGuarantee(this.guaranteeId);
}
