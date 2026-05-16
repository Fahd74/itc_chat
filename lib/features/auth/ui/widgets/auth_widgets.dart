import 'package:flutter/material.dart';
import 'package:itc_chat/features/auth/ui/screens/signup_screen.dart';

// --- دالة لبناء الأزرار (Reusable Component) ---
Widget buildButton({
  required String text,
  required Color bgColor,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 17)),
    ),
  );
}

// Widget buildWelcomeTitle() {
//     return RichText(
//       text: const TextSpan(
//         text: 'Welcome ',
//         style: TextStyle(color: Color(0xFF00BFA5), fontSize: 28, fontWeight: FontWeight.bold),
//         children: [
//           TextSpan(text: 'Back', style: TextStyle(color: Colors.white)),
//         ],
//       ),
//     );
//   }

Widget buildInputField({
  required String label,
  required String hint,
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF004D40)),
          ),
        ),
      ),
    ],
  );
}

Widget buildPrimaryButton({required String text}) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00796B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    ),
  );
}

Widget buildDivider() {
  return const Row(
    children: [
      Expanded(child: Divider(color: Color(0xFF004D40))),
      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Or Continue With")),
      Expanded(child: Divider(color: Color(0xFF004D40))),
    ],
  );
}

Widget buildSocialButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [socialIcon(), const SizedBox(width: 20), socialIcon()],
  );
}

Widget socialIcon() {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
  );
}

// Widget buildSignUpPrompt() {
//   return Center(
//     child: RichText(
//       text: const TextSpan(
//         text: "Don't Have An Account? ",
//         children: [
//           TextSpan(text: "Sign Up", style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
//         ],
//       ),
//     ),
//   );
// }

// زر الرجوع المشترك
Widget buildBackButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: IconButton(
      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
      onPressed: () {
        // العودة للشاشة السابقة إذا وجدت (Navigation Logic)
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
    ),
  );
}

// نص "Sign Up" في أسفل شاشة الـ Login
Widget buildSignUpPrompt(BuildContext context) {
  return Center(
    child: TextButton(
      onPressed: () {
        // الانتقال لشاشة إنشاء الحساب (Navigation)
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
      },
      child: RichText(
        text: TextSpan(
          text: 'Don’t Have An Account ? ',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ج. كلاس لمربعات الـ OTP (OTP Input Box)
class OtpInputBox extends StatelessWidget {
  const OtpInputBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1, // رقم واحد فقط
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none, // إزالة الحدود الافتراضية للـ TextField
          counterText: '', // إخفاء عداد الحروف
        ),
      ),
    );
  }
}

// عنوان "Welcome Back" المدمج
Widget buildWelcomeTitle(BuildContext context) {
  return Center(
    child: RichText(
      text: TextSpan(
        text: 'Welcome ',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Back',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    ),
  );
}
