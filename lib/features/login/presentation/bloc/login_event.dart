abstract class LoginEvent {}
class PressLogin extends LoginEvent {
  final String phone;
  final String password;

  PressLogin({required this.phone,required this.password});
}