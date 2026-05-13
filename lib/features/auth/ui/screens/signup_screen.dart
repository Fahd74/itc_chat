import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_state.dart';
import 'package:itc_chat/core/constants/constants.dart';
import 'package:itc_chat/features/auth/ui/widgets/custom_app_text_field.dart';
import 'package:itc_chat/features/auth/ui/widgets/auth_widgets.dart';
import 'package:itc_chat/features/auth/ui/widgets/primary_app_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _yearController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _yearController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signup(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Force dark background as in ui2
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBackButton(context),
                    const SizedBox(height: 30),
                    const Text('Create Account', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Lorem Ipsum Dolor Sit Amet Consectetur...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 40),
                    
                    // استخدام الـ Widgets المشتركة
                    CustomAppTextField(
                      label: 'Full Name',
                      hint: 'Enter',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'يرجى إدخال الاسم';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomAppTextField(
                      label: 'University Email',
                      hint: 'Enter',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                        if (!value.contains('@')) return 'يرجى إدخال بريد إلكتروني صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomAppTextField(
                      label: 'Password',
                      hint: 'Enter Password',
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'يرجى إدخال كلمة المرور';
                        if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomAppTextField(
                      label: 'Academic Year',
                      hint: 'Year 1',
                      controller: _yearController,
                    ),
                    const SizedBox(height: 20),
                    CustomAppTextField(
                      label: 'Department',
                      hint: 'IT',
                      controller: _departmentController,
                    ),
                    
                    const SizedBox(height: 50),
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                    else
                      PrimaryAppButton(text: 'Continue', onPressed: _signup),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
