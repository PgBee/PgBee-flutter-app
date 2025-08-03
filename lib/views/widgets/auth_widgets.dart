import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:provider/provider.dart';




class AuthWidgets {

  static Consumer authChoice(){
    return Consumer<AuthProvider>(
      builder: (context, provider, child){
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallPhone = screenWidth < 360;
        final isTablet = screenWidth >= 600;
        final isDesktop = screenWidth >= 900;
        
        final height = isDesktop ? 72.0 : 
                      isTablet ? 64.0 : 
                      isSmallPhone ? 52.0 : 56.0;
        
        final fontSize = isDesktop ? 22.0 : 
                        isTablet ? 20.0 : 
                        isSmallPhone ? 16.0 : 18.0;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: provider.changeAuth,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: provider.isSignUp ? LightColor.black : Colors.white,
                          border: Border.all(
                            width: 1.5,
                            color: provider.isSignUp ? Colors.transparent : LightColor.grey.withOpacity(0.5),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: provider.isSignUp ? Colors.white : LightColor.black,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            child: const Text('Sign up'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: provider.changeAuth,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: !provider.isSignUp ? LightColor.black : Colors.white,
                          border: Border.all(
                            width: 1.5,
                            color: !provider.isSignUp ? Colors.transparent : LightColor.grey.withOpacity(0.5),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: !provider.isSignUp ? Colors.white : LightColor.black,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            child: const Text('Log in'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } 
    );
  }

  // Google SignUp or Sign In Widget
// static Container googleAuth({
//   required BuildContext context,
//   required AuthProvider authProvider,
// }) {
//   return Container(
//     width: double.infinity,
//     height: 56,
//     decoration: ShapeDecoration(
//       color: LightColor.background,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           width: 1,
//           color: LightColor.grey,
//         ),
//         borderRadius: BorderRadius.circular(25),
//       ),
//     ),
//     child: TextButton.icon(
//       onPressed: () async {
//         // Show loading dialog
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return const AlertDialog(
//               content: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(width: 16),
//                   Text('Signing in with Google...'),
//                 ],
//               ),
//             );
//           },
//         );

//         try {
//           // Call Google Sign-In service
//           final result = await authProvider.googleSignIn();
          
//           // Close loading dialog
//           Navigator.of(context).pop();
          
//           if (result) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(authProvider.isSignUp ? 'Signed up with Google successfully!' : 'Logged in with Google successfully!')),
//             );
//             // Navigate to root layout after successful Google sign in
//             Navigator.pushReplacementNamed(context, '/home');
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(authProvider.errorMessage ?? 'Google authentication failed')),
//             );
//           }
//         } catch (e) {
//           // Close loading dialog
//           Navigator.of(context).pop();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Google Sign-In error: ${e.toString()}')),
//           );
//         }
//       },
//       icon: Image.network(
//         'https://www.google.com/favicon.ico',
//         width: 20,
//         height: 20,
//       ),
//       label: Text(
//         authProvider.isSignUp ? 'Sign up with Google' : 'Log In with Google',
//         style: TextStyle(
//           color: LightColor.black,
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       style: TextButton.styleFrom(
//         backgroundColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(25),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//     ),
//   );
// }

  // Divider
  static Widget divider(){
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;
        final isTablet = screenWidth >= 600;
        
        final fontSize = isDesktop ? 16.0 : 
                        isTablet ? 15.0 : 14.0;
        
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0x4C424242).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: const Color(0xFF424242).withOpacity(0.8),
                  fontSize: fontSize,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
                child: const Text('OR'),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0x4C424242).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  // Text Form Field and Name Widget
  static Widget formField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required TextInputType type,
    required String? Function(String?) validator
  }){
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallPhone = screenWidth < 360;
        final isTablet = screenWidth >= 600;
        final isDesktop = screenWidth >= 900;
        
        final height = isDesktop ? 64.0 : 
                      isTablet ? 60.0 : 
                      isSmallPhone ? 52.0 : 56.0;
        
        final fontSize = isDesktop ? 18.0 : 
                        isTablet ? 17.0 : 16.0;
        
        final titleFontSize = isDesktop ? 18.0 : 
                             isTablet ? 17.0 : 16.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w500,
                color: LightColor.black,
                fontFamily: 'Poppins',
              ),
              child: Text(title),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16, 
                vertical: 8
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1.5,
                  color: LightColor.grey.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                cursorColor: LightColor.black,
                keyboardType: type,
                controller: controller,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: LightColor.black,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: LightColor.grey.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                validator: validator
              ),
            ),
          ],
        );
      }
    );
  }

  // Password Form
  static Widget passwordField({
    required String? Function(String?) validator,
    required AuthProvider authProvider,
    required TextEditingController controller
  }){
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallPhone = screenWidth < 360;
        final isTablet = screenWidth >= 600;
        final isDesktop = screenWidth >= 900;
        
        final height = isDesktop ? 64.0 : 
                      isTablet ? 60.0 : 
                      isSmallPhone ? 52.0 : 56.0;
        
        final fontSize = isDesktop ? 18.0 : 
                        isTablet ? 17.0 : 16.0;
        
        final titleFontSize = isDesktop ? 18.0 : 
                             isTablet ? 17.0 : 16.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w500,
                color: LightColor.black,
                fontFamily: 'Poppins',
              ),
              child: const Text('Password'),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16, 
                vertical: 8
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1.5,
                  color: LightColor.grey.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: controller,
                      obscureText: authProvider.obscurePassword,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w400,
                        color: LightColor.black,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          color: LightColor.grey.withOpacity(0.7),
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: validator,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: authProvider.changeVisibility,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            authProvider.obscurePassword ? Icons.visibility_off : Icons.visibility,
                            key: ValueKey(authProvider.obscurePassword),
                            color: LightColor.grey,
                            size: isDesktop ? 24 : 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
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
  static Widget forgetPassword(){
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;
        final isTablet = screenWidth >= 600;
        
        final fontSize = isDesktop ? 15.0 : 
                        isTablet ? 14.0 : 12.0;
        
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Handle forgot password
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: LightColor.grey.withOpacity(0.8),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.underline,
                    decorationColor: LightColor.grey.withOpacity(0.6),
                  ),
                  child: const Text('Forgot Your Password?'),
                ),
              ),
            ),
          ),
        );
      }
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
          height: 56,
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
              Expanded(
                child: Row(
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
                    Flexible(
                      child: Text(
                        'I\'m not a robot',
                        style: AppTheme.h6Style,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/recaptcha.png',
                    fit: BoxFit.contain,
                  )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}