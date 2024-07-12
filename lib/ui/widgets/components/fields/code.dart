import 'package:flutter/material.dart';
import 'package:newsapp/ui/widgets/components/fields/text_field.dart';

class OTPField extends StatelessWidget {
  final TextEditingController controller;
  final bool? autoFocus;
  final TextInputAction? textInputAction;
  final void Function(String text)? onChanged;

  const OTPField({
    super.key,
    required this.controller,
    this.textInputAction,
    this.autoFocus,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      autoFocus: autoFocus ?? false,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction ?? TextInputAction.next,
      width: 30,
      height: 40,
    );
  }
}
