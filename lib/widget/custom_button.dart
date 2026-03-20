import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? textColor;
  final Color strokeColor;
  final Color? backgroundColor;
  final double height;
  final double width;
  final Widget? icon;
  final double iconSize;
  final bool hasStroke;
  final double fontSize;
  final bool hasShadow;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 50.0,
    this.width = double.infinity,
    this.icon,
    this.iconSize = 22.0,
    this.hasStroke = false,
    this.strokeColor = const Color(0xFFE0E0E0),
    this.fontSize = 16.0,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,

          side: hasStroke
              ? BorderSide(color: strokeColor, width: 1)
              : BorderSide.none,

          elevation: hasShadow ? 4.0 : 0.0,
          shadowColor: hasShadow ? Colors.black.withOpacity(0.5) : Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          disabledBackgroundColor: backgroundColor?.withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
