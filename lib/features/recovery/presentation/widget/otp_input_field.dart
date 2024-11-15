import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPCodeTextField extends StatelessWidget {
  const OTPCodeTextField({
    super.key,
    required this.onComplete,
    required this.otpController,
  });

  final Function(String) onComplete;
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      controller: otpController,
      autoDisposeControllers:false,
      appContext: context,
      length: 4,
      obscureText: false,
      cursorColor: const Color(0xffDDDDDD),
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.black,
      ),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(20),
        fieldHeight: 51,
        fieldWidth: 51,
        activeColor: const Color(0xffDDDDDD),
        // Change color for active input
        selectedColor: const Color(0xffDDDDDD),
        // Selected color
        inactiveColor: const Color(0xffDDDDDD),
        // Inactive input border
        borderWidth: 1.6,
      ),
      onCompleted: (value) => onComplete(value),
    );
  }
}