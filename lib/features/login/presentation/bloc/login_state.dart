import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class LoginState {}
class LoginInitial extends LoginState{}
class LoginLoading extends LoginState{}
class LoginSuccess extends LoginState{
  UserModel user;

  LoginSuccess(this.user);
}
class LoginError extends LoginState{
  String error;

  LoginError(this.error);
}