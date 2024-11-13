import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mbosswater/core/constants/error_message.dart';
import 'package:mbosswater/core/utils/storage.dart';
import 'package:mbosswater/features/recovery/domain/usecase/change_password.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordUseCase _changePassword;
  String currentPasswordError = "";
  String newPasswordError = "";
  String reNewPasswordError = "";

  ChangePasswordBloc(this._changePassword) : super(ChangeInitial()) {
    on<PressedChangePassword>(_handleChangePassword);
    on<PressedChangePasswordByEmail>(_handleChangePasswordByEmail);
  }

  FutureOr<void> _handleChangePassword(
      PressedChangePassword event, emit) async {
    try {
      emit(ChangeLoading());
      await _changePassword.call(event.oldPassword, event.newPassword);
      emit(ChangeSuccess());
    } on Exception catch (e) {
      currentPasswordError = ErrorMessage.IUI_ERROR_CURRENT_PASSWORD_INCORRECT;
      emit(ChangeError(e.toString()));
    }
  }

  FutureOr<void> _handleChangePasswordByEmail(
      PressedChangePasswordByEmail event, emit) async {
    try {
      emit(ChangeLoading());
      UserModel userEntity =
          await _changePassword(event.email, event.newPassword);
      await StorageUtils.storeValue(key: "role", value: userEntity.role);
      emit(ChangeSuccess());
    } on Exception catch (e) {
      emit(ChangeError(e.toString()));
    }
  }

  void emitError(String errorMessage) {
    emit(ChangeError(errorMessage));
  }

  void changePasswordInitial() {
    newPasswordError = "";
    currentPasswordError = "";
    reNewPasswordError = "";
    emit(ChangeInitial());
  }
}

// State
class ChangePasswordState {}

class ChangeInitial extends ChangePasswordState {}

class ChangeLoading extends ChangePasswordState {}

class ChangeError extends ChangePasswordState {
  String message;

  ChangeError(this.message);
}

class ChangeSuccess extends ChangePasswordState {}

// Event
class ChangePasswordEvent {}

class PressedChangePassword extends ChangePasswordEvent {
  String newPassword, oldPassword;

  PressedChangePassword({required this.newPassword, required this.oldPassword});
}

class PressedChangePasswordByEmail extends ChangePasswordEvent {
  String email, newPassword;

  PressedChangePasswordByEmail(
      {required this.email, required this.newPassword});
}
