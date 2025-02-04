import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_state.dart';

class GuaranteeHistoryBloc
    extends Bloc<GuaranteeHistoryEvent, GuaranteeHistoryState> {
  final GuaranteeHistoryUseCase useCase;

  GuaranteeHistoryBloc(this.useCase) : super(GuaranteeHistoryInitial()) {
    on<FetchListGuaranteeHistory>(_onFetchListHistory);
    on<CreateGuaranteeHistory>(_onCreateHistory);
  }

  Future<void> _onFetchListHistory(FetchListGuaranteeHistory event,
      Emitter<GuaranteeHistoryState> emit) async {
    try {
      emit(GuaranteeHistoryLoading());
      final guaranteeHistories =
          await useCase.fetchListGuaranteeHistory(event.guaranteeID);
      emit(GuaranteeHistoryListLoaded(guaranteeHistories));
    } catch (e) {
      emit(GuaranteeHistoryError('Failed to add active guarantee: $e'));
    }
  }

  Future<void> _onCreateHistory(CreateGuaranteeHistory event,
      Emitter<GuaranteeHistoryState> emit) async {
    try {
      emit(GuaranteeHistoryLoading());
      await useCase.create(event.guaranteeHistory);
      emit(CreateGuaranteeHistorySuccess());
    } catch (e) {
      emit(GuaranteeHistoryError('Failed to add guarantee history: $e'));
    }
  }
}
