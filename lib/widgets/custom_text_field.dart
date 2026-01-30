import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: themeProvider.getTextColor(),
      ),
      cursorColor: themeProvider.getPrimaryColor(),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: themeProvider.getLabelColor(),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: themeProvider.getIconColor(),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldBorderColor(),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldFocusColor(),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getErrorColor(),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getErrorColor(),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: themeProvider.getInputFieldColor(),
      ),
    );
  }
}
