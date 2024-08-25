import 'package:flutter/material.dart';

class RoundedMaterialTextFormField extends StatelessWidget {
  final Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final Widget? prefixIcon, suffixIcon;
  final String? hintText, initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool disabled, obscureText, filled, isClearable;
  final FocusNode? focus, nextFocus;
  final TextEditingController? controller;
  final int? minLines;
  final int? maxLines;

  const RoundedMaterialTextFormField({
    super.key,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.focus,
    this.nextFocus,
    this.disabled = false,
    this.filled = false,
    this.textInputAction,
    this.suffixIcon,
    this.initialValue,
    this.isClearable = false,
    this.obscureText = false,
    this.controller,
    this.minLines,
    this.maxLines,
    required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged,
      enabled: !disabled,
      validator: validator,
      focusNode: focus,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction ??
          (nextFocus != null ? TextInputAction.next : TextInputAction.done),
      onFieldSubmitted: (v) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      keyboardType: keyboardType ??
          (minLines != null && minLines != 1
              ? TextInputType.multiline
              : TextInputType.text),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
            horizontal: 18, vertical: minLines != null ? 8 : 0),
        hintText: hintText,
        hintStyle: const TextStyle(height: 3),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon ??
            (isClearable && (controller?.text ?? '').isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller?.clear();
                      onChanged?.call('');
                    },
                  )
                : null),
        filled: disabled ? true : filled,
        fillColor: Colors.grey[200],
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: filled ? Colors.transparent : Colors.grey),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: filled ? Colors.transparent : Colors.grey),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
