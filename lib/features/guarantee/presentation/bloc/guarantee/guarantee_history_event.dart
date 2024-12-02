import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';

abstract class GuaranteeHistoryEvent {}
class FetchListGuaranteeHistory extends GuaranteeHistoryEvent{
  final String guaranteeID;

  FetchListGuaranteeHistory(this.guaranteeID);
}

class CreateGuaranteeHistory extends GuaranteeHistoryEvent{
  final GuaranteeHistory guaranteeHistory;

  CreateGuaranteeHistory(this.guaranteeHistory);
}