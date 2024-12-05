
import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  IconData suffixIcon = Icons.visibility;
  late bool isShow;


  @override
  void initState() {
    super.initState();
    isShow = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 18, right: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.inputFieldColor,
        border: Border.all(color: const Color(0xffE8ECF4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: TextField(
                controller: widget.controller,
                obscureText: isShow,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: "BeVietnam",
                    color: AppColors.textInputColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                cursorColor: AppColors.textInputColor,
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: AppColors.textInputColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          widget.obscureText
              ? IconButton(
            onPressed: () {
              setState(() {
                if (isShow) {
                  suffixIcon = Icons.visibility_off;
                } else {
                  suffixIcon = Icons.visibility;
                }
                isShow = !isShow;
              });
            },
            icon: Icon(
              suffixIcon,
              size: 22,
              color: Colors.grey,
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}