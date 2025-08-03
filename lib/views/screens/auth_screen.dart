import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/core/utils/button_widgets.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/views/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';
import 'package:pgbee/models/auth_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeSession();
    // If already logged in, navigate to home
    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  // Validators
  // first Name Validator 
  String? firstNameValidator(String? value){
    if(value == null || value.isEmpty){
      return 'Enter First name';
    }
    return null;
  }

  // last name Validator
  String? lastNameValidator(String? value){
    if(value == null || value.isEmpty){
      return 'Enter Last name';
    }
    return null;
  }

  // Email Validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Invalid email format';
    return null;
}

  // Password Validator
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
  final TextEditingController _phoneController = TextEditingController();
  // Phone number validator
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter phone number';
    }
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // form Key
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  // on Submit the Sign In Button
  Future<void> onSubmitSignIn() async{
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_signInFormKey.currentState!.validate()) {
      final success = await authProvider.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        // Navigate to root layout after successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
        );
      }
    }
  }

  // on Submit the Sign Up Button
  Future<void> onSubmitSignUp() async{
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_signUpFormKey.currentState!.validate()) {
      final authModel = AuthModel(
        firstName: _fNameController.text,
        lastName: _lNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNo: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );
      final success = await authProvider.signUp(authModel);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Registration failed')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Better responsive breakpoints
    final isSmallPhone = screenWidth < 360;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;
    
    // Dynamic padding based on screen size
    final horizontalPadding = isDesktop ? screenWidth * 0.15 : 
                             isTablet ? screenWidth * 0.1 : 
                             isSmallPhone ? 12.0 : 16.0;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isMobile ? 16 : 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dynamic top spacing
                  SizedBox(height: isDesktop ? screenHeight * 0.08 : 
                                   isTablet ? screenHeight * 0.06 : 
                                   screenHeight * 0.04),
                  
                  // Logo - Enhanced responsive sizing with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 500 : 
                               isTablet ? 400 : 
                               screenWidth * 0.8,
                      maxHeight: isDesktop ? 100 : 
                                isTablet ? 80 : 
                                isSmallPhone ? 50 : 60,
                    ),
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? screenHeight * 0.06 : 
                                   isTablet ? screenHeight * 0.05 : 
                                   screenHeight * 0.04),

                  // Main container - Enhanced responsive design
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 600 : 
                               isTablet ? 500 : 
                               double.infinity,
                    ),
                    padding: EdgeInsets.all(
                      isDesktop ? 40 : 
                      isTablet ? 32 : 
                      isSmallPhone ? 16 : 24
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          width: 2,
                          color: LightColor.grey.withOpacity(0.3)
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Sign Up / Log In toggle buttons
                        AuthWidgets.authChoice(),

                        SizedBox(height: isDesktop ? screenHeight * 0.04 : 
                                        isTablet ? screenHeight * 0.035 : 
                                        screenHeight * 0.03),
                        
                        // // Google Sign In/Up button
                        // AuthWidgets.googleAuth(context: context, authProvider: authProvider),
                        // const SizedBox(height: 24),

                        // OR divider
                        AuthWidgets.divider(),
                        SizedBox(height: isDesktop ? screenHeight * 0.04 : 
                                        isTablet ? screenHeight * 0.035 : 
                                        screenHeight * 0.03),

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
                            SizedBox(height: isSmallPhone ? 16 : 20),

                            // Last Name
                            AuthWidgets.formField(
                              validator: lastNameValidator,
                              type: TextInputType.name,
                              title: 'Last name', 
                              controller: _lNameController, 
                              hintText: 'Doe'
                            ),
                            SizedBox(height: isSmallPhone ? 16 : 20),

                            // Phone Number
                            AuthWidgets.formField(
                              validator: phoneValidator,
                              type: TextInputType.phone,
                              title: 'Phone Number',
                              controller: _phoneController,
                              hintText: 'Enter your phone number',
                            ),
                            SizedBox(height: isSmallPhone ? 16 : 20),

                            // Email
                            AuthWidgets.formField(
                              validator: validateEmail,
                              title: 'Email', 
                              controller: _emailController, 
                              hintText: 'Enter your email address', 
                              type: TextInputType.emailAddress
                            ),
                            SizedBox(height: isSmallPhone ? 16 : 20),

                            // Password
                            AuthWidgets.passwordField(
                              validator: passwordValidator,
                              authProvider: authProvider,
                              controller: _passwordController
                            ),
                            SizedBox(height: isDesktop ? 32 : 
                                            isTablet ? 28 : 24),

                              // Terms and conditions for sign up
                              AuthWidgets.termsAndCondition(authProvider: authProvider),

                              // Sign Up Submit Button
                              SizedBox(height: isDesktop ? 40 : 
                                              isTablet ? 36 : 32),
                              ButtonWidgets.textButton(
                                context: context,
                                onPressed: onSubmitSignUp,
                                height: isDesktop ? 72 : 
                                       isTablet ? 64 : 
                                       isSmallPhone ? 52 : 56, 
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
                              SizedBox(height: isSmallPhone ? 16 : 20),

                              // Password
                              AuthWidgets.passwordField(
                                validator: passwordValidator,
                                authProvider: authProvider,
                                controller: _passwordController
                              ),
                              SizedBox(height: 12),

                              // Forget Password Widget
                              AuthWidgets.forgetPassword(),
                              SizedBox(height: isDesktop ? 32 : 
                                              isTablet ? 28 : 24),

                              // Captcha for login
                              AuthWidgets.captacha(),

                              // Submit Button of Log in
                              SizedBox(height: isDesktop ? 40 : 
                                              isTablet ? 36 : 32),
                              ButtonWidgets.textButton(
                                context: context,
                                onPressed: onSubmitSignIn,
                                height: isDesktop ? 72 : 
                                       isTablet ? 64 : 
                                       isSmallPhone ? 52 : 56, 
                                width: double.maxFinite, 
                                name: 'Log In'
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? screenHeight * 0.08 : 
                                   screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}