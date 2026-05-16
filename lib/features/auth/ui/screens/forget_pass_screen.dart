import 'package:flutter/material.dart';
import 'package:itc_chat/features/auth/ui/widgets/primary_app_button.dart';
import '../widgets/auth_widgets.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: buildBackButton(context)),
              const SizedBox(height: 40),

              // 1. الأيقونة البديلة للأفاتار (Icon Object)
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.security_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Password Recovery',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter 4-digits code we sent you on\nyour phone number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '+03*******00',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // صف مربعات الـ OTP (Row composed of OtpInputBox objects)
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [OtpInputBox(), OtpInputBox(), OtpInputBox(), OtpInputBox()],
              ),

              const SizedBox(height: 60),
              PrimaryAppButton(text: 'Done', onPressed: () {}),

              const SizedBox(height: 15),
              // زر Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
