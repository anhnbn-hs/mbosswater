abstract class GuaranteeHistoryEvent {}
class FetchListGuaranteeHistory extends GuaranteeHistoryEvent{
  final String guaranteeID;

  FetchListGuaranteeHistory(this.guaranteeID);
}