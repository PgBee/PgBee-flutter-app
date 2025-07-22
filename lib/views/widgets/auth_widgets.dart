import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
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
                        color: !provider.isSignUp ? LightColor.black : LightColor.background,
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
    required AuthProvider authProvider
  }){
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
        onPressed: () {},
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
}