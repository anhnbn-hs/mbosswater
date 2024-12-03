import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/recovery/domain/usecase/verify_email.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_event.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final VerifyEmailUseCase _checkEmail;

  String email = "";

  VerifyEmailBloc(this._checkEmail) : super(VerifyEmailInitial()) {
    on<PressedVerifyEmail>(_handleCheckEmail);
  }

  FutureOr<void> _handleCheckEmail(PressedVerifyEmail event, emit) async {
    try {
      emit(VerifyEmailLoading());
      bool isSuccess = await _checkEmail(event.email);
      if (isSuccess) {
        emit(VerifyEmailSuccess(event.email));
        email = event.email;
      } else {
        emit(VerifyEmailError("Vui lòng nhập lại email"));
      }
    } on Exception {
      emit(VerifyEmailError("Vui lòng nhập lại email"));
    }
  }

  void emitError(String error) => emit(VerifyEmailError(error));
  void emitInitial() => emit(VerifyEmailInitial());
}
