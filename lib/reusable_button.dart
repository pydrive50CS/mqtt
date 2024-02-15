import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final String? text;
  final double? height;
  final double? width;
  final Color? color;
  final Color? textColor;
  final Function()? onPressed;
  final double borderRadius;
  final Widget? child;

  const ReusableButton({
    super.key,
    this.text,
    this.height,
    this.width,
    this.color,
    required this.onPressed,
    this.borderRadius = 5,
    this.textColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 0),
      height: height ?? 35,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: child ??
            Text(
              text!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }
}
