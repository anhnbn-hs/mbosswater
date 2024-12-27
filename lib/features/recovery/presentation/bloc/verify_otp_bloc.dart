import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_event.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {

  VerifyOtpBloc() : super(VerifyOTPInitial()) {
    on<HandleVerifyOTP>(_handleVerify);
  }

  FutureOr<void> _handleVerify(HandleVerifyOTP event, emit) async {
    try {
      emit(VerifyOTPLoading());
      /// Todo Verify OTP
      ///
    } on Exception {
      emit(VerifyOTPError());
    }
  }
}
