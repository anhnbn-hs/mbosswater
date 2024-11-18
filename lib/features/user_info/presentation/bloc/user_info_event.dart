abstract class UserInfoEvent {}

class FetchUserInfo extends UserInfoEvent {
  final String userID;

  FetchUserInfo(this.userID);
}