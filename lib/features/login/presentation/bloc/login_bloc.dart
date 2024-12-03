import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_event.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDatasource authDatasource;

  LoginBloc(this.authDatasource) : super(LoginInitial()) {
    on<PressLogin>(
      (event, emit) async {
        try {
          emit(LoginLoading());

          User? user = await authDatasource.loginWithEmailAndPassword(
            event.email,
            event.password,
          );

          if (user != null) {
            emit(LoginSuccess(user));
          } else {
            emit(LoginError("User not found"));
          }
        } on Exception catch (e) {
          emit(LoginError(e.toString()));
        }
      },
    );
  }

  void reset(){
    emit(LoginInitial());
  }
}
