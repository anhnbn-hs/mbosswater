import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/active_guarantee.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_state.dart';

class ActiveGuaranteeBloc extends Bloc<ActiveGuaranteeEvent, ActiveGuaranteeState> {
  final ActiveGuaranteeUseCase useCase;

  ActiveGuaranteeBloc(this.useCase) : super(ActiveGuaranteeInitial()) {
    on<ActiveGuarantee>(_onAddActiveGuarantee);
  }

  Future<void> _onAddActiveGuarantee(
      ActiveGuarantee event, Emitter<ActiveGuaranteeState> emit) async {
    try {
      await useCase.call(event.guarantee, event.customer);
      emit(ActiveGuaranteeLoaded(event.guarantee, event.customer));
    } catch (e) {
      emit(ActiveGuaranteeError('Failed to add active guarantee: $e'));
    }
  }

  void reset(){
    emit(ActiveGuaranteeInitial());
  }
}
