import 'package:flutter/material.dart';

class CustomAppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;

  final TextEditingController? controller;
  final String? Function(String?)? validator;

  // Constructor باستخدام Named Parameters لتخصيص كل حقل
  const CustomAppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false, // افتراضياً ليس كلمة مرور
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // نص العنوان فوق الحقل
        Text(
          label,
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        // كلاس الـ TextFormField هو الـ Property الأساسي هنا
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword, // إخفاء النص إذا كانت كلمة مرور
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest, // لون خلفية الحقل
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            // حدود الحقل بشكل دائري كما في التصميم
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
