import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/study_logo.png',
      width: width,
      height: height,
      fit: BoxFit.fill,
      excludeFromSemantics: true,
    );
  }
}
