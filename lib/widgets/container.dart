import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double? height;
  final double width;
  final double blur;
  final double elevation;
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  CustomContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.height,
    this.width = double.infinity,
    this.blur = 10.0,
    this.elevation = 0,
    this.color = Colors.white30,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.all(20),
  }) : this.borderRadius = borderRadius ?? BorderRadius.circular(20.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: BlurryContainer(
        child: child,
        blur: blur,
        height: height,
        width: width,
        elevation: elevation,
        color: color,
        borderRadius: borderRadius,
        padding: padding,
      ),
    );
  }
}
