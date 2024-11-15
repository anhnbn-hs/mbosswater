import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/features/login/presentation/page/login_page.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_event.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_state.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_event.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_state.dart';
import 'package:mbosswater/features/recovery/presentation/widget/otp_input_field.dart';
import 'package:mbosswater/features/recovery/presentation/widget/resend_button.dart';

import '../../../../injection_container.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  final otpController = TextEditingController();

  late VerifyEmailBloc verifyEmailBloc;
  late VerifyOtpBloc verifyOtpBloc;

  @override
  void initState() {
    super.initState();
    verifyEmailBloc = BlocProvider.of<VerifyEmailBloc>(context);
    verifyOtpBloc = BlocProvider.of<VerifyOtpBloc>(context);
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
              BlocBuilder(
                bloc: verifyEmailBloc,
                builder: (context, state) {
                  if (state is VerifyEmailError) {
                    DialogUtils.hide(context);
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.error,
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
              const SizedBox(height: 40),
              CustomElevatedButton(
                text: "GỬI MÃ OTP",
                onTap: () => handleSendOTP(context),
              ),
              BlocBuilder(
                bloc: verifyEmailBloc,
                builder: (context, state) {
                  if (state is VerifyEmailSuccess) {
                    DialogUtils.hide(context);
                    verifyOtpBloc.sendOTP(emailController.text);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Mã OTP đã được gửi đến email",
                          style: TextStyle(
                            color: AppColors.textErrorColor,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ResendButton(
                          onResend: () {
                            handleSendOTP(context);
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          margin: const EdgeInsets.only(top: 40),
                          child: OTPCodeTextField(
                            otpController: otpController,
                            onComplete: (value) {
                              verifyOtpBloc.add(HandleVerifyOTP(value));
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocListener(
                bloc: verifyOtpBloc,
                listener: (context, state) {
                  if (state is VerifyOTPSuccess) {
                    context.push("/change-password");
                  }
                  if (state is VerifyOTPError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryColor,
                        content: const Text(
                          "Vui lòng nhập lại mã OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleSendOTP(BuildContext context) {
    DialogUtils.showLoadingDialog(context);
    if (emailController.text.isEmpty) {
      verifyEmailBloc.emitError("Vui lòng nhập lại email");
    } else {
      verifyEmailBloc.add(PressedVerifyEmail(emailController.text));
    }
  }
}
