import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:provider/provider.dart';




class AuthWidgets {

  static Consumer authChoice(){
    return Consumer<AuthProvider>(
      builder: (context, provider, child){
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: provider.changeAuth,
                child: Container(
                  height: 56,
                  decoration: ShapeDecoration(
                    color: provider.isSignUp ? LightColor.black : LightColor.background,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: provider.isSignUp ? Colors.transparent : const Color(0x4C424242),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: provider.isSignUp ? LightColor.background : LightColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: provider.changeAuth,
                child: Container(
                  height: 56,
                  decoration: ShapeDecoration(
                    color: !provider.isSignUp ? LightColor.black : LightColor.background,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: !provider.isSignUp ? Colors.transparent : LightColor.black,
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
                        color: !provider.isSignUp ? LightColor.background : LightColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } 
    );
  }

  // Google SignUp or Sign In Widget
static Container googleAuth({
  required BuildContext context,
  required AuthProvider authProvider,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: ShapeDecoration(
      color: LightColor.background,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: LightColor.grey,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
    ),
    child: TextButton.icon(
      onPressed: () async {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Signing in with Google...'),
                ],
              ),
            );
          },
        );

        try {
          // Call Google Sign-In service
          final result = await authProvider.googleSignIn();
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.isSignUp ? 'Signed up with Google successfully!' : 'Logged in with Google successfully!')),
            );
            // Navigate to root layout after successful Google sign in
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage ?? 'Google authentication failed')),
            );
          }
        } catch (e) {
          // Close loading dialog
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Sign-In error: ${e.toString()}')),
          );
        }
      },
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
      ),
      label: Text(
        authProvider.isSignUp ? 'Sign up with Google' : 'Log In with Google',
        style: TextStyle(
          color: LightColor.black,
          fontSize: 16,
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
  );
}

  // Divider
  static Row divider(){
    return Row(
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
    );
  }

  // Text Form Field and Name Widget
  static Column formField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required TextInputType type,
    required String? Function(String?) validator
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.h6Style
        ),
        SizedBox(height: 8),
        Container(
          height: 61,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: LightColor.grey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: TextFormField(
            cursorColor: LightColor.black,
            keyboardType: type,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.h6Style,
              border: InputBorder.none,
            ),
            validator: validator
          ),
        ),
      ],
    );
  }

  // Password Form
  static Column passwordField({
    required String? Function(String?) validator,
    required AuthProvider authProvider,
    required TextEditingController controller
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTheme.h6Style
        ),
        const SizedBox(height: 8),
        Container(
          height: 61,
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: LightColor.grey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: controller,
                  obscureText: authProvider.obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTheme.h6Style,
                    border: InputBorder.none,
                  ),
                  validator: validator,
                ),
              ),
              GestureDetector(
                onTap: authProvider.changeVisibility,
                child: Icon(
                  authProvider.obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: LightColor.appPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Terms and Condition Widget
  static Column termsAndCondition({
    required AuthProvider authProvider
  }){
    return Column(
      children: [ 
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: authProvider.changeAgreeTerms,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: LightColor.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  color: authProvider.agreeToTerms ? LightColor.black : Colors.transparent,
                ),
                child: authProvider.agreeToTerms
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: LightColor.background,
                  )
                : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'By creating an account, I agree to our ',
                  style: TextStyle(
                    color: LightColor.grey,
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
    );
  }

  // Forget Password Widget
  static Align forgetPassword(){
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // Handle forgot password
        },
        child: Text(
          'Forgot Your Password?',
          style: TextStyle(
            color: LightColor.grey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  // Captcha Widget 
  static Column captacha(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Captcha',
          style: AppTheme.h6Style
        ),
        const SizedBox(height: 8),
        Container(
          width: double.maxFinite,
          height: 61,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: LightColor.grey,
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
                        color: LightColor.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: LightColor.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'I\'m not a robot',
                    style: AppTheme.h6Style
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Center(
                  child: Image.asset('assets/images/recaptcha.png')
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}