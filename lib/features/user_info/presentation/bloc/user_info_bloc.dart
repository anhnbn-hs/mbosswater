import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/domain/usecase/fetch_user_info.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_event.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final FetchUserInfoUseCase _fetchUserInfoUseCase;
  UserModel? user;
  UserInfoBloc(this._fetchUserInfoUseCase) : super(UserInfoInitial()) {
    on<FetchUserInfo>((event, emit) async {
      emit(UserInfoLoading());
      try {
        final user = await _fetchUserInfoUseCase.call(event.userID);
        emit(UserInfoLoaded(user));
        this.user = user;
      } catch (error) {
        emit(UserInfoError(error.toString()));
      }
    });
  }

  void reset(){
    user = null;
    emit(UserInfoInitial());
  }
}