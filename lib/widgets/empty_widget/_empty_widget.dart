import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/constant.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.message,
  });

  final TextSpan? message;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 260),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/empty_placeholder.png"),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox.square(dimension: 12),
            Text.rich(
              message!,
              style: _theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Avatar Widget
class CircleAvatarWidget extends StatelessWidget {
  final String? name;
  final Size? size;

  const CircleAvatarWidget({super.key, this.name, this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: size?.height ?? 50,
      width: size?.width ?? 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kMainColor50,
      ),
      clipBehavior: Clip.antiAlias,
      child: Text(
        (name != null && name!.length >= 2) ? name!.substring(0, 2) : (name != null ? name! : ''),
        style: theme.textTheme.titleMedium?.copyWith(
          color: kMainColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EmptyWidgetUpdated extends StatelessWidget {
  const EmptyWidgetUpdated({
    super.key,
    this.message,
  });

  final TextSpan? message;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/empty_image.svg',
            width: 319,
            height: 250,
            placeholderBuilder: (BuildContext context) => CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox.square(dimension: 12),
            Text.rich(
              message!,
              textAlign: TextAlign.center,
              style: _theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class PermitDenyWidget extends StatefulWidget {
  const PermitDenyWidget({
    super.key,
    this.message,
  });

  final TextSpan? message;

  @override
  State<PermitDenyWidget> createState() => _PermitDenyWidgetState();
}

class _PermitDenyWidgetState extends State<PermitDenyWidget> with TickerProviderStateMixin {
  // Track drag offsets
  double _dragX = 0;
  double _dragY = 0;

  // Animation controller for fade-in & reset bounce
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  // Animation controller for bounce-back effect after drag ends
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimationX;
  late Animation<double> _bounceAnimationY;

  // Limits for rotation angles (radians)
  static const double maxRotationX = 0.15; // ~8.6 degrees
  static const double maxRotationY = 0.15;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceAnimationX =
        Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut))
          ..addListener(() {
            setState(() {
              _dragX = _bounceAnimationX.value;
            });
          });

    _bounceAnimationY =
        Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut))
          ..addListener(() {
            setState(() {
              _dragY = _bounceAnimationY.value;
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_bounceController.isAnimating) _bounceController.stop();

    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;

      _dragX = _dragX.clamp(-100, 100);
      _dragY = _dragY.clamp(-100, 100);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Animate back to center with bounce
    _bounceAnimationX = Tween<double>(begin: _dragX, end: 0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    )..addListener(() {
        setState(() {
          _dragX = _bounceAnimationX.value;
        });
      });

    _bounceAnimationY = Tween<double>(begin: _dragY, end: 0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    )..addListener(() {
        setState(() {
          _dragY = _bounceAnimationY.value;
        });
      });

    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rotationY = (_dragX / 100) * maxRotationY;
    final rotationX = -(_dragY / 100) * maxRotationX;
    final dragDistance = (_dragX.abs() + _dragY.abs()) / 200;
    final scale = 1 - (dragDistance * 0.07);

    // Add a glowing border on drag to emphasize interaction
    final glowColor = theme.colorScheme.primary.withOpacity(0.4 * dragDistance);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateX(rotationX)
                ..rotateY(rotationY)
                ..scale(scale),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceVariant.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: glowColor,
                    width: dragDistance > 0 ? 2 : 0,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SvgPicture.asset(
                        'assets/empty_image.svg',
                        width: 320,
                        height: 260,
                        placeholderBuilder: (context) => const CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      widget.message ??
                          TextSpan(
                            text: "You don't have the necessary permissions.",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: theme.colorScheme.onBackground,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Please contact your administrator to request access.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
