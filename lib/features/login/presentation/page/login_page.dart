import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/error_message.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_bloc.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_event.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_state.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController, passwordController;

  // BLOC
  late LoginBloc loginBloc;
  late UserInfoBloc userInfoBloc;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // Init bloc
    loginBloc = BlocProvider.of<LoginBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
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
                controller: emailController,
                hintText: "Email",
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
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              BlocBuilder(
                bloc: loginBloc,
                builder: (context, state) {
                  if (state is LoginError) {
                    DialogUtils.hide(context);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ErrorMessage.IUI_ERROR_INVALID_CREDENTIALS,
                        style: TextStyle(
                          color: AppColors.textErrorColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  if (state is LoginSuccess) {
                    DialogUtils.hide(context);
                    // Save FCM Token

                    // Get User Information
                    userInfoBloc.add(FetchUserInfo(state.user.uid));
                    // Navigate
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      while (context.canPop()) {
                        context.pop();
                      }
                      context.push("/home");
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 30),
              CustomElevatedButton(
                text: "ĐĂNG NHẬP",
                onTap: handleLogin,
              )
            ],
          ),
        ),
      ),
    );
  }

  handleLogin() async {
    // Get text field value
    String email = emailController.text;
    String password = passwordController.text;
    // Show loading dialog
    DialogUtils.showLoadingDialog(context);
    String? token = await FirebaseMessaging.instance.getToken();
    print("LOGIN TOKEN: ${token}");
    loginBloc.add(PressLogin(
      email: email,
      password: password,
    ));
  }

}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey,
      child: Ink(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "BeVietnam",
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
