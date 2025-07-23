import 'package:flutter/material.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ButtonWidgets {
  static GestureDetector textButton({
    required Future<void> Function({required AuthProvider provider}) onPressed,
    required double height,
    required double width,
    required String name,
    required BuildContext context
  }){
    return GestureDetector(
      onTap: (){
        onPressed(provider: Provider.of<AuthProvider>(context, listen: false));
      },
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              color: Color(0xFFFAFAFA),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}