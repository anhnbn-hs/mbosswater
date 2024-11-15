abstract class VerifyEmailState {}
class VerifyEmailInitial extends VerifyEmailState {
}
class VerifyEmailLoading extends VerifyEmailState {
}
class VerifyEmailSuccess extends VerifyEmailState {
  String email;

  VerifyEmailSuccess(this.email);
}
class VerifyEmailError extends VerifyEmailState {
  String error;

  VerifyEmailError(this.error);
}

