
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/error_message.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_bloc.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_event.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_state.dart';
import 'package:mbosswater/features/notification/notification_cubit.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController phoneController, passwordController;

  // BLOC
  late LoginBloc loginBloc;
  late UserInfoBloc userInfoBloc;
  late NotificationCubit notificationCubit;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    // Init bloc
    loginBloc = BlocProvider.of<LoginBloc>(context);
    notificationCubit = BlocProvider.of<NotificationCubit>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    loginBloc.reset();
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
                controller: phoneController,
                hintText: "Số điện thoại",
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: passwordController,
                hintText: "Mật khẩu",
                obscureText: true,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push("/forgot-password"),
                  child: const Text(
                    "Quên mật khẩu ?",
                    style: TextStyle(
                      fontFamily: "BeVietnam",
                      color: Color(0xff6A707C),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              BlocConsumer(
                bloc: loginBloc,
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Make sure the context is valid here
                      if (mounted) {
                        while (context.canPop()) {
                          context.pop();
                        }
                        context.go("/home");
                      }

                      // Get User Information after navigation
                      userInfoBloc.add(FetchUserInfo(state.user.id));
                      notificationCubit.fetchNotifications(state.user.id);
                    });
                  }
                },
                builder: (context, state) {
                  if (state is LoginError) {
                    DialogUtils.hide(context);
                    return Container(
                      padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ErrorMessage.IUI_ERROR_INVALID_CREDENTIALS,
                        style: TextStyle(
                          fontFamily: "BeVietnam",
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
              const SizedBox(height: 30),
              CustomButton(
                textButton: "ĐĂNG NHẬP",
                onTap: () async => handleLogin(),
              )
            ],
          ),
        ),
      ),
    );
  }

  handleLogin() async {
    // Get text field value
    String phone = phoneController.text;
    String password = passwordController.text;

    if (phone.trim().isEmpty || password.trim().isEmpty) {
      return;
    }

    // Show loading dialog
    DialogUtils.showLoadingDialog(context);

    loginBloc.add(PressLogin(
      phone: phone,
      password: password,
    ));
  }
}
