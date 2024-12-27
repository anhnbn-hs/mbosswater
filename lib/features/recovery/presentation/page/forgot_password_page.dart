import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/custom_textfield.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  final otpController = TextEditingController();

  late VerifyOtpBloc verifyOtpBloc;

  @override
  void initState() {
    super.initState();
    verifyOtpBloc = BlocProvider.of<VerifyOtpBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
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
                hintText: "Số điện thoại",
              ),
              const SizedBox(height: 40),
              CustomButton(
                textButton: "GỬI MÃ OTP",
                onTap: () => handleSendOTP(context),
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
                            fontFamily: "BeVietnam",
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
    DialogUtils.showWarningDialog(
      context: context,
      title: "Tính năng đang được phát triển do chuyển từ Email -> SDT",
      onClickOutSide: () {},
    );

    // DialogUtils.showLoadingDialog(context);

    // if (emailController.text.isEmpty) {
    //   verifyEmailBloc.emitError("Vui lòng nhập lại email");
    // } else {
    //   // verifyEmailBloc.add(PressedVerifyEmail(emailController.text));
    // }
  }
}
