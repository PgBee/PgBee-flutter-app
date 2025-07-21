import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 300,
                  height: 50,
                ),
                const SizedBox(height: 60),
                // Main container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFAFAFA),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0x4C424242),
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0C2A2A2A),
                        blurRadius: 17,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sign Up / Log In toggle buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isSignUp = true),
                              child: Container(
                                height: 56,
                                decoration: ShapeDecoration(
                                  color: isSignUp ? const Color(0xFF1F1F1F) : const Color(0xFFFAFAFA),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: isSignUp ? Colors.transparent : const Color(0x4C424242),
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: isSignUp ? const Color(0xFFFAFAFA) : const Color(0xFF1F1F1F),
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isSignUp = false),
                              child: Container(
                                height: 56,
                                decoration: ShapeDecoration(
                                  color: !isSignUp ? const Color(0xFF1F1F1F) : const Color(0xFFFAFAFA),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: !isSignUp ? Colors.transparent : const Color(0x4C424242),
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Log in',
                                    style: TextStyle(
                                      color: !isSignUp ? const Color(0xFFFAFAFA) : const Color(0xFF1F1F1F),
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Google Sign In/Up button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAFAFA),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFF424242),
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: Image.network(
                            'https://www.google.com/favicon.ico',
                            width: 20,
                            height: 20,
                          ),
                          label: Text(
                            isSignUp ? 'Sign up with Google' : 'Log In with Google',
                            style: const TextStyle(
                              color: Color(0xFF1F1F1F),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // OR divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0x4C424242),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0x4C424242),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Form fields
                      if (isSignUp) ...[
                        // First Name
                        const Text(
                          'First name',
                          style: TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x4C424242),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'John',
                              hintStyle: TextStyle(
                                color: Color(0x80424242),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Last Name
                        const Text(
                          'Last name',
                          style: TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x4C424242),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Doe',
                              hintStyle: TextStyle(
                                color: Color(0x80424242),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x4C424242),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your email address',
                            hintStyle: TextStyle(
                              color: Color(0x80424242),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x4C424242),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                obscureText: _obscurePassword,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    color: Color(0x80424242),
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF424242),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isSignUp) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Handle forgot password
                            },
                            child: const Text(
                              'Forgot Your Password?',
                              style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Captcha for login
                        const Text(
                          'Verify Captcha',
                          style: TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x4C424242),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF424242),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'I\'m not a robot',
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'reCAPTCHA',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isSignUp) ...[
                        const SizedBox(height: 24),
                        // Terms and conditions for sign up
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF424242),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  color: _agreeToTerms ? const Color(0xFF1F1F1F) : Colors.transparent,
                                ),
                                child: _agreeToTerms
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  text: 'By creating an account, I agree to our ',
                                  style: TextStyle(
                                    color: Color(0xFF424242),
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of use',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                      // Sign Up/Log In button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF1F1F1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isSignUp ? 'Sign Up' : 'Log In',
                            style: const TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}