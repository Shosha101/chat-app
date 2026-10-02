import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

//Themes
import '../themes/app_theme.dart';

// One pattern for the login and register forms, so both accept the same addresses
const String emailRegEx = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String hintText;
  final bool obscureText;
  // Shown under the field when the value does not match [regEx]
  final String? errorText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const CustomTextFormField(
      {super.key,
        required this.onSaved,
        required this.regEx,
        required this.hintText,
        required this.obscureText,
        this.errorText,
        this.icon,
        this.keyboardType,
        this.textInputAction});

  // Spaces around a name or an email are typing slips; a password is kept as typed
  String _clean(String? value) {
    return obscureText ? (value ?? '') : (value ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (value) => onSaved(_clean(value)),
      style: const TextStyle(color: AppColors.text, fontSize: 15),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      validator: (value) {
        return RegExp(regEx).hasMatch(_clean(value))
            ? null
            : errorText ?? context.tr('error_value');
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Function(String) onEditingComplete;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData? icon;

  const CustomTextField(
      {super.key,
        required this.onEditingComplete,
        required this.hintText,
        required this.obscureText,
        required this.controller,
        this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onEditingComplete: () => onEditingComplete(controller.value.text),
      style: const TextStyle(color: AppColors.text, fontSize: 15),
      obscureText: obscureText,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon == null ? null : Icon(icon, size: 22),
        // Clears the field and runs the search again without a name
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: context.tr('clear'),
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                controller.clear();
                onEditingComplete('');
              },
            );
          },
        ),
      ),
    );
  }
}
