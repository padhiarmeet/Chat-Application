import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keybordType;
  final Widget? prefixIcon;
  final Widget? sufixIcon;
  final FocusNode? focusNode;
  final int? maxLength;
  final String? Function(String?)? validator;
  const CustomTextfield({super.key, required this.controller, required this.hintText, this.obscureText = false, this.keybordType, this.prefixIcon, this.sufixIcon, this.focusNode, this.validator, this.maxLength});



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keybordType,
      focusNode: focusNode,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: sufixIcon,
        counterText: ''


      ),

    );
  }
}
