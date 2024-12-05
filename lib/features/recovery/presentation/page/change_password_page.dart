import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/error_message.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/features/login/presentation/page/login_page.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/change_password_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final passwordController = TextEditingController();

  final rePasswordController = TextEditingController();

  late ChangePasswordBloc changePasswordBloc;

  late VerifyEmailBloc verifyEmailBloc;

  @override
  void initState() {
    super.initState();
    changePasswordBloc = BlocProvider.of<ChangePasswordBloc>(context);
    verifyEmailBloc = BlocProvider.of<VerifyEmailBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    changePasswordBloc.changePasswordInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 150,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "MbossWater",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: passwordController,
                hintText: "Mật khẩu mới",
                obscureText: true,
              ),
              BlocBuilder(
                bloc: changePasswordBloc,
                builder: (context, state) {
                  if (state is ChangeError &&
                      changePasswordBloc.newPasswordError != "") {
                    DialogUtils.hide(context);
                    return Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          color: AppColors.textErrorColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: rePasswordController,
                hintText: "Nhập lại mật khẩu",
                obscureText: true,
              ),
              BlocBuilder(
                bloc: changePasswordBloc,
                builder: (context, state) {
                  if (state is ChangeError &&
                      changePasswordBloc.reNewPasswordError != "") {
                    DialogUtils.hide(context);
                    return Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          fontFamily: "BeVietnam",
                          color: AppColors.textErrorColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  if (state is ChangeSuccess) {
                    DialogUtils.hide(context);
                    // Get User Information
                    // Navigate
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.push("/home");
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 30),
              CustomElevatedButton(
                text: "ĐỔI MẬT KHẨU",
                onTap: () => handleChangePassword(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleChangePassword(BuildContext context) {
    // Reset
    changePasswordBloc.currentPasswordError = "";
    changePasswordBloc.newPasswordError = "";
    changePasswordBloc.reNewPasswordError = "";

    DialogUtils.showLoadingDialog(context);
    String password = passwordController.text;
    String rePassword = rePasswordController.text;

    String pattern =
        r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d!\-\+\/\\@#$%^&*(),.?":{}|<>]{8,}$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(password)) {
      changePasswordBloc.newPasswordError =
          ErrorMessage.IUI_ERROR_WEAK_PASSWORD;
      changePasswordBloc.emitError(ErrorMessage.IUI_ERROR_WEAK_PASSWORD);
      return;
    }

    if (password != rePassword) {
      changePasswordBloc.reNewPasswordError =
          ErrorMessage.IUI_ERROR_PASSWORD_CONFIRMATION_MISMATCH;
      changePasswordBloc
          .emitError(ErrorMessage.IUI_ERROR_PASSWORD_CONFIRMATION_MISMATCH);
      return;
    }

    changePasswordBloc.add(PressedChangePasswordByEmail(
      email: verifyEmailBloc.email,
      newPassword: password,
    ));
  }
}
