import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';

abstract class GuaranteeHistoryState {}
class GuaranteeHistoryInitial extends GuaranteeHistoryState{}
class GuaranteeHistoryLoading extends GuaranteeHistoryState{}
class GuaranteeHistoryListLoaded extends GuaranteeHistoryState{
  final List<GuaranteeHistory> guaranteeHistories;

  GuaranteeHistoryListLoaded(this.guaranteeHistories);
}
class GuaranteeHistoryError extends GuaranteeHistoryState{
  final String error;

  GuaranteeHistoryError(this.error);
}