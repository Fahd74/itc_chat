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
          style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        // كلاس الـ TextFormField هو الـ Property الأساسي هنا
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword, // إخفاء النص إذا كانت كلمة مرور
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.black26, // لون خلفية الحقل
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            // حدود الحقل بشكل دائري كما في التصميم
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF004D40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00BFA5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
