import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_state.dart';
import 'package:itc_chat/features/auth/ui/screens/forget_pass_screen.dart';
import 'package:itc_chat/core/constants/constants.dart';
import 'package:itc_chat/features/auth/ui/widgets/custom_app_text_field.dart';
import 'package:itc_chat/features/auth/ui/widgets/auth_widgets.dart';
import 'package:itc_chat/features/auth/ui/widgets/primary_app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
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
                  children: [
                    const SizedBox(height: 40),

                    // 1. الأيقونة البديلة للأفاتار (Icon Object)
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF1E272E),
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 80,
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Ai Assistant',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    buildWelcomeTitle(),

                    const SizedBox(height: 60),

                    // استخدام الـ Widgets المشتركة
                    CustomAppTextField(
                      label: 'University Email',
                      hint: 'Enter',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomAppTextField(
                      label: 'Password',
                      hint: 'Enter',
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),

                    // رابط "Forget Password؟"
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // الانتقال لشاشة استعادة كلمة المرور (Navigation)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgetPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forget Password?',
                          style: TextStyle(color: Color(0xFF00BFA5)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    if (state is AuthLoading)
                      const CircularProgressIndicator(color: Color(0xFF00BFA5))
                    else
                      PrimaryAppButton(text: 'Log In', onPressed: _login),

                    const SizedBox(height: 30),
                    // نص "Sign Up"
                    buildSignUpPrompt(context),
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
