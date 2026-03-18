import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield extends StatefulWidget {
  final String hintText; //label input crud
  final IconData? icon;
  final bool isObscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextfield({
    super.key,
    required this.hintText,
    this.icon,
    this.isObscure = false,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _isTextVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isObscure && !_isTextVisible,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: const Color(0xFF7A7A7A))
            : null,

        //Logic obscure input text
        suffixIcon: widget.isObscure
            ? IconButton(
                icon: Icon(
                  _isTextVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF7A7A7A),
                ),
                onPressed: () {
                  setState(() {
                    _isTextVisible = !_isTextVisible;
                  });
                },
              )
            : widget.suffixIcon,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8A8A8A), width: 1.5),
        ),
      ),
    );
  }
}
