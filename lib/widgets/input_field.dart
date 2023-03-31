import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.size,
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  final Size size;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.2,
      padding: EdgeInsets.symmetric(horizontal: size.width / 13),
      margin: EdgeInsets.symmetric(
          horizontal: size.width / 14, vertical: size.height / 35),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(200, 168, 201, 0.3),
                blurRadius: 20,
                offset: Offset(0, 10)),
          ],
          borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: size.width / 1.5,
        child: Center(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
