import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/core/widgets/splash_logo.dart';

const _backgroundColor = Color(0xFF171838);
const _wordmarkColor = Color(0xFFE1B70F);
const _designSize = Size(402, 874);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoPosition;
  late final Animation<Size> _logoSize;
  late final Animation<Offset> _ellipsePosition;
  late final Animation<double> _wordmarkOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _logoOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 82),
    ]).animate(_controller);
    _logoPosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(135, 212)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(135, 212),
          end: const Offset(146, 402),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(146, 402),
          end: const Offset(22, 405),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(22, 405)),
        weight: 34,
      ),
    ]).animate(_controller);
    _logoSize = TweenSequence<Size>([
      TweenSequenceItem(
        tween: ConstantTween<Size>(const Size(137, 121)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<Size>(
          begin: const Size(137, 121),
          end: const Size(110, 93),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Size>(const Size(110, 93)),
        weight: 54,
      ),
    ]).animate(_controller);
    _ellipsePosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(40, 450)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(40, 450),
          end: const Offset(38, 495),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(38, 495)),
        weight: 54,
      ),
    ]).animate(_controller);
    _wordmarkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 66),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 12),
    ]).animate(_controller);
    _controller.addStatusListener(_handleAnimationStatus);
    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.of(context).pushReplacementNamed<void, void>('/login');
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / _designSize.width,
            constraints.maxHeight / _designSize.height,
          );
          final canvasWidth = _designSize.width * scale;
          final canvasHeight = _designSize.height * scale;

          return Center(
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final logoPosition = _logoPosition.value;
                  final logoSize = _logoSize.value;
                  final ellipsePosition = _ellipsePosition.value;

                  return Stack(
                    children: [
                      Positioned(
                        left: ellipsePosition.dx * scale,
                        top: ellipsePosition.dy * scale,
                        width: 326 * scale,
                        height: 106 * scale,
                        child: SvgPicture.asset(
                          'assets/images/ellipse_fill.svg',
                          width: 326 * scale,
                          height: 106 * scale,
                        ),
                      ),
                      Positioned(
                        left: logoPosition.dx * scale,
                        top: logoPosition.dy * scale,
                        width: logoSize.width * scale,
                        height: logoSize.height * scale,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: SplashLogo(
                            width: logoSize.width * scale,
                            height: logoSize.height * scale,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 143 * scale,
                        top: 431 * scale,
                        width: 243 * scale,
                        height: 76 * scale,
                        child: Opacity(
                          opacity: _wordmarkOpacity.value,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.topLeft,
                              widthFactor: 1,
                              child: SizedBox(
                                width: 306 * scale,
                                child: Text(
                                  'V - Study',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: _wordmarkColor,
                                    fontFamily: 'Jomhuria',
                                    fontSize: 100 * scale,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
