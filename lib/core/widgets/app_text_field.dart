import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Стилізоване поле введення з плаваючою міткою та іконкою.
/// Для паролів (isPassword: true) додає кнопку показу/приховування символів.
/// Працює всередині Form: [validator] повертає текст помилки або null.
class AppTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? initialValue;
  final String? helperText;
  final bool autofocus;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

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
    this.enabled = true,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
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
      enabled: widget.enabled,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      style: const TextStyle(fontSize: 17, color: AppColors.text),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        errorMaxLines: 2,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.error)
              ? AppColors.error
              : states.contains(WidgetState.focused)
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
