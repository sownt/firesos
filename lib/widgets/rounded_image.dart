import 'package:flutter/material.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({required this.imageUrl, Key? key}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
        color: Colors.black
        ),
        child: Image.network(imageUrl),
      ),
    );
  }
}