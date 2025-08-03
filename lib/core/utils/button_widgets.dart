import 'package:flutter/material.dart';

class ButtonWidgets {
  static Widget textButton({
    required Future<void> Function() onPressed,
    required double height,
    required double width,
    required String name,
    required BuildContext context
  }){
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 900;
    
    final fontSize = isDesktop ? 22.0 : 
                    isTablet ? 20.0 : 
                    isSmallPhone ? 16.0 : 18.0;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2D2D2D),
                Color(0xFF1F1F1F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: const Color(0xFFFAFAFA),
                fontSize: fontSize,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              child: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}