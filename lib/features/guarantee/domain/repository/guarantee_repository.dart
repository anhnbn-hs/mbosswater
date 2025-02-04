import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';

abstract class GuaranteeRepository {
  Future<void> createGuarantee(
    Guarantee guarantee,
    Customer customer,
    Reminder reminder,
    ActionType actionType,
  );

  Future<Agency> fetchAgency(String agencyID);

  Future<List<Agency>> fetchAgencies();

  Future<Customer?> getCustomerExisted(String phoneNumber);

  Future<List<GuaranteeHistory>> fetchGuaranteeHistoryList(String guaranteeID);

  Future<void> createGuaranteeHistory(GuaranteeHistory gHistory);
}
