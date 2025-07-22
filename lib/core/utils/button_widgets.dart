import 'package:flutter/material.dart';

class ButtonWidgets {
  static Container textButton({
    required double height,
    required double width,
    required String name
  }){
    return Container(
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
    );
  }
}