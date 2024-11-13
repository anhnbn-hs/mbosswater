abstract class VerifyOtpEvent {}

class HandleVerifyOTP extends VerifyOtpEvent {
  String otp;

  HandleVerifyOTP(this.otp);
}
