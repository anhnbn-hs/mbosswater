import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_event.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_state.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDatasource authDatasource;

  LoginBloc(this.authDatasource) : super(LoginInitial()) {
    on<PressLogin>(
      (event, emit) async {
        try {
          emit(LoginLoading());

          UserModel user = await authDatasource.loginWithPhoneNumberAndPassword(
            event.phone,
            event.password,
          );

          emit(LoginSuccess(user));
        } on Exception catch (e) {
          emit(LoginError(e.toString()));
        }
      },
    );
  }

  void emitError(String error) {
    emit(LoginError(error));
  }

  void reset() {
    emit(LoginInitial());
  }
}
