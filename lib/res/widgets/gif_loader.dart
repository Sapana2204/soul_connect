import 'package:flutter/material.dart';

class GifLoader extends StatelessWidget {
  const GifLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/gif/loader.gif',
        width: 100,
        height: 100,
      ),
    );
  }
}
