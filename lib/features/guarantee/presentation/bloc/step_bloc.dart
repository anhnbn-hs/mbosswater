import 'package:bloc/bloc.dart';

class StepBloc extends Cubit<int> {
  int currentStep = 0;

  StepBloc(this.currentStep) : super(0);

  void changeStep(int step) {
    currentStep = step;
    emit(currentStep);
  }

  void goToNextStep() {
    currentStep++;
    emit(currentStep);
  }

  void goToPreviousStep() {
    currentStep--;
    emit(currentStep);
  }
}
