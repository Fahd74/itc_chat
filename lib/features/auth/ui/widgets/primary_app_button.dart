// ب. الزر الرئيسي المخصص (Custom Primary Button)
import 'package:flutter/material.dart';

class PrimaryAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; // وظيفة الزر عند الضغط (Callback)

  const PrimaryAppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ليكون بعرض الشاشة بالكامل
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor, // Theme primary
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        onPressed: onPressed, // هنا سنربط الـ Cubit لاحقاً
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // توسيط محتويات الزر أفقياً
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            // أيقونة سهم (Composition)
            Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
