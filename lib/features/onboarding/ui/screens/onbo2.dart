import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // زر الـ Skip 
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF1AB5A9),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/Rectangle 160684.png'), 
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(width: 80, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  _buildDot(width: 40, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  _buildDot(width: 40, color: const Color(0xFF1AB5A9)),
                ],
              ),

              const SizedBox(height: 40),

              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Public Sans',
                  ),
                  children: [
                    TextSpan(text: ' Your', style: TextStyle(color: Color(0xFF0F766E))),
                    TextSpan(text: 'Personal Academic ', style: TextStyle(color: Color(0xFF1AB5A9))),
                    TextSpan(text: ' Guide', style: TextStyle(color: Color(0xFF0F766E))),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                " Think of me as your 24/7 Class Rep. I’m here to organize your schedule, answer your academic queries, and keep you on track for success.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9C9C9C),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Next
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required double width, required Color color}) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
  
}