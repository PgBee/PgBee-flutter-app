import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:pgbee/views/screens/auth_screen.dart';
import 'package:pgbee/views/screens/root_layout.dart';

class NetworkingArenaPage extends StatefulWidget {
  const NetworkingArenaPage({super.key});

  @override
  State<NetworkingArenaPage> createState() => _NetworkingArenaPageState();
}

class _NetworkingArenaPageState extends State<NetworkingArenaPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Rotation animation for orbital rings
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Pulse animation for the globe
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Orbit animation for dots
    _orbitController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    // Floating animation for particles
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer animation for welcome text
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

                const SizedBox(height: 20),
                
                // Logo


          // Enhanced background with gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 400,
                  height: 200,
                ),
                const SizedBox(height: 60),
          // Floating particles background
          ...List.generate(15, (index) {
            return AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final randomX = (index * 50.0) % screenWidth;
                final randomY = (index * 80.0) % screenHeight;
                
                return Positioned(
                  left: randomX + (20 * math.sin(_floatingController.value * 2 * math.pi + index)),
                  top: randomY + (30 * math.cos(_floatingController.value * 2 * math.pi + index)),
                  child: Opacity(
                    opacity: (0.1 + (0.2 * math.sin(_floatingController.value * 2 * math.pi + index))).clamp(0.0, 1.0),
                    child: Container(
                      width: 4 + (index % 3),
                      height: 4 + (index % 3),
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? const Color(0xFFFFEB67) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (index % 2 == 0 ? const Color(0xFFFFEB67) : Colors.white).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Enhanced welcome text with shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.8),
                              const Color(0xFFFFEB67),
                              Colors.white.withOpacity(0.8),
                            ],
                            stops: [
                              0.0,
                              _shimmerController.value,
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                            
                          ),
                        ),
                      );
                    },
                  ),

                  // Subtitle text
                  

                  const Spacer(flex: 1),

                  // Enhanced 3D Globe with improved visual effects
                  SizedBox(
                    height: 420,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _rotationController,
                        _pulseController,
                        _orbitController,
                      ]),
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow effect
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFAFAFA).withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Enhanced Globe with pulse effect and inner glow
                            Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.08),
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF424242),
                                      const Color(0xFF303030),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFAFAFA).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 0),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFFEB67).withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 0),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: Stack(
                                    children: [
                                      // Inner gradient overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            center: const Alignment(-0.3, -0.3),
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Home icon with enhanced styling
                                      Center(
                                        child: Transform.scale(
                                          scale: 1.0 + (_pulseController.value * 0.05),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  const Color(0xFFFFEB67).withOpacity(0.2),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.home_rounded,
                                              size: 65,
                                              color: const Color(0xFFFFEB67).withOpacity(0.9),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Enhanced Orbital rings with improved visual effects
                            ...List.generate(3, (index) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * math.pi + (index * 1.2),
                                child: Container(
                                  width: 220 + (index * 40),
                                  height: 220 + (index * 40),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5 - (index * 0.1)),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Enhanced orbital dots with varied sizes and colors
                                      ...List.generate(6 + index, (dotIndex) {
                                        final angle = (dotIndex / (6 + index)) * 2 * math.pi +
                                            (_orbitController.value * 2 * math.pi * (index % 2 == 0 ? 1 : -1));
                                        final radius = (110 + (index * 20)).toDouble();
                                        final dotSize = 5.0 + (index * 1.5);
                                        
                                        return Positioned(
                                          left: radius + radius * 0.9 * math.cos(angle),
                                          top: radius + radius * 0.9 * math.sin(angle),
                                          child: Transform.scale(
                                            scale: 1.0 + (0.4 * math.sin(_orbitController.value * 2 * math.pi + dotIndex)),
                                            child: Container(
                                              width: dotSize,
                                              height: dotSize,
                                              decoration: BoxDecoration(
                                                gradient: RadialGradient(
                                                  colors: [
                                                    dotIndex % 3 == 0 
                                                        ? const Color(0xFFFFEB67)
                                                        : dotIndex % 3 == 1
                                                            ? const Color(0xFFFAFAFA)
                                                            : Colors.white,
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (dotIndex % 3 == 0 
                                                        ? const Color(0xFFFFEB67)
                                                        : dotIndex % 3 == 1
                                                            ? const Color(0xFFFAFAFA)
                                                            : Colors.white).withOpacity(0.6),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Enhanced Get Started button with premium styling
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.03),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFEB67), Color(0xFFFFEB67)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFEB67).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, -2),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RootLayout(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}