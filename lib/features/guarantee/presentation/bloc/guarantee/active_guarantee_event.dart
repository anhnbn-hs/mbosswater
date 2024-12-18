import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';

abstract class ActiveGuaranteeEvent {}

class ActiveGuarantee extends ActiveGuaranteeEvent {
  final Guarantee guarantee;
  final Customer customer;
  final Reminder reminder;
  final ActionType actionType;

  ActiveGuarantee(
      this.guarantee, this.customer, this.reminder, this.actionType);
}

class RemoveActiveGuarantee extends ActiveGuaranteeEvent {
  final String guaranteeId;

  RemoveActiveGuarantee(this.guaranteeId);
}
