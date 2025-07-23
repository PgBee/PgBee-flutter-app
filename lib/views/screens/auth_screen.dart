import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/core/utils/button_widgets.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/views/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  // Validator
  // first Name
  String? firstNameValidator(String? value){
    if(value == null || value.isEmpty){
      return 'Enter First name';
    }
    return null;
  }

  // last name
  String? lastNameValidator(String? value){
    if(value == null || value.isEmpty){
      return 'Enter Last name';
    }
    return null;
  }

  // Email 
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Invalid email format';
    return null;
}

  // Password
  String? passwordValidator(String? value){
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }



  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();

  // form Key
  final GlobalKey _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey _signInFormKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppTheme.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                  height: 50,
                ),
                const SizedBox(height: 60),

                // Main container
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: LightColor.grey
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Sign Up / Log In toggle buttons
                      AuthWidgets.authChoice(),

                      const SizedBox(height: 24),
                      
                      // Google Sign In/Up button
                      AuthWidgets.googleAuth(authProvider: authProvider),
                      const SizedBox(height: 24),

                      // OR divider
                      AuthWidgets.divider(),
                      const SizedBox(height: 24),

                      // Form field of SignUp
                      if (authProvider.isSignUp) Form(
                        key: _signUpFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Name
                            AuthWidgets.formField(
                              validator: firstNameValidator,
                              type: TextInputType.name,
                              title: 'First name', 
                              controller: _fNameController, 
                              hintText: 'John'
                            ),
                            const SizedBox(height: 16),

                            // Last Name
                            AuthWidgets.formField(
                              validator: lastNameValidator,
                              type: TextInputType.name,
                              title: 'Last name', 
                              controller: _lNameController, 
                              hintText: 'Doe'
                            ),
                            const SizedBox(height: 16),

                            // Email
                            AuthWidgets.formField(
                              validator: validateEmail,
                              title: 'Email', 
                              controller: _emailController, 
                              hintText: 'Enter your email address', 
                              type: TextInputType.emailAddress
                            ),
                            const SizedBox(height: 16),

                            // Password
                            AuthWidgets.passwordField(
                              validator: passwordValidator,
                              authProvider: authProvider,
                              controller: _passwordController
                            ),
                            const SizedBox(height: 24),

                            // Terms and conditions for sign up
                            AuthWidgets.termsAndCondition(authProvider: authProvider),

                            // Sign Up Submit Button
                            const SizedBox(height: 40),
                            ButtonWidgets.textButton(
                              height: 56, 
                              width: double.maxFinite, 
                              name: 'Sign Up'
                            )
                            
                          ],
                        ),
                      )
                      // Form field of Sign In 
                      else Form(
                        key: _signInFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Email
                            AuthWidgets.formField(
                              validator: validateEmail,
                              title: 'Email', 
                              controller: _emailController, 
                              hintText: 'Enter your email address', 
                              type: TextInputType.emailAddress
                            ),
                            const SizedBox(height: 16),

                            // Password
                            AuthWidgets.passwordField(
                              validator: passwordValidator,
                              authProvider: authProvider,
                              controller: _passwordController
                            ),
                            const SizedBox(height: 8),

                            // Forget Password Widget
                            AuthWidgets.forgetPassword(),
                            const SizedBox(height: 24),

                            // Captcha for login
                            AuthWidgets.captacha(),

                            // Submit Button of Log in
                            const SizedBox(height: 40),
                            ButtonWidgets.textButton(
                              height: 56, 
                              width: double.maxFinite, 
                              name: 'Login In'
                            )
                          ],
                        )
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