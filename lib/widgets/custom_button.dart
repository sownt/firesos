import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.size,
    required this.text,
    required this.onTap,
  });
  final Size size;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height / 14,
        width: size.width / 1.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: onTap != null ? Colors.red[900] : Colors.grey,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w300, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
