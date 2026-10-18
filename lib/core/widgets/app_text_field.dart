import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Стилізоване поле введення з плаваючою міткою та іконкою.
/// Для паролів (isPassword: true) додає кнопку показу/приховування символів.
class AppTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? initialValue;
  final String? helperText;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.helperText,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      style: const TextStyle(fontSize: 17, color: AppColors.text),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? AppColors.primary
              : AppColors.muted,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscured ? 'Показати пароль' : 'Приховати пароль',
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
