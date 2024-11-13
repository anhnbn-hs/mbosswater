abstract class VerifyEmailEvent {}

class PressedVerifyEmail extends VerifyEmailEvent {
  String email;

  PressedVerifyEmail(this.email);
}
