abstract class LoginEvent {}
class PressLogin extends LoginEvent {
  final String email;
  final String password;

  PressLogin({required this.email,required this.password});
}