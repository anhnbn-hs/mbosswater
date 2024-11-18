import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class UserInfoState {}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoLoaded extends UserInfoState {
  final UserModel user;

  UserInfoLoaded(this.user);
}

class UserInfoError extends UserInfoState {
  final String message;

  UserInfoError(this.message);
}