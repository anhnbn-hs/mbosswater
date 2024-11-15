import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:email_otp/email_otp.dart';
import 'package:mbosswater/features/recovery/domain/usecase/verify_email.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_event.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final VerifyEmailUseCase _useCase;

  VerifyOtpBloc(this._useCase) : super(VerifyOTPInitial()) {
    on<HandleVerifyOTP>(_handleVerify);
  }

  FutureOr<void> _handleVerify(HandleVerifyOTP event, emit) async {
    try {
      emit(VerifyOTPLoading());
      bool isVerified = EmailOTP.verifyOTP(otp: event.otp);
      isVerified ? emit(VerifyOTPSuccess()) : emit(VerifyOTPError());
    } on Exception catch (e) {
      emit(VerifyOTPError());
    }
  }

  Future<void> sendOTP(String email) async {
    return await _useCase.sendOTP(email);
  }
}
