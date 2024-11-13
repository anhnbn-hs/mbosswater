import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mbosswater/core/constants/error_message.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_bloc.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_event.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController, passwordController;

  // BLOC
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // Init bloc
    loginBloc = BlocProvider.of<LoginBloc>(context);
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
                  child: Text(
                    "Quên mật khẩu ?",
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xff6A707C),
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
                    // Get User Information
                    // Navigate
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      while (context.canPop()) {
                        context.pop();
                      }
                      context.push("/home-page");
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

  void handleLogin() {
    String email = emailController.text;
    String password = passwordController.text;
    DialogUtils.showLoadingDialog(context);
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
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
