import 'package:flutter/material.dart';

Color primary = const Color(0xFF554CCD);
Color lightYellow = const Color(0xFFFFFFFB);
Color black = const Color(0xFF000000);
Color grey = const Color(0xFF8C8E8C);
Color lightGrey = const Color(0xFFD3D3D3);
Color white = Colors.white;
Color buttonColor = Colors.greenAccent.shade700;
Color blue = const Color(0xFF092C4C);
Color blue2 = const Color(0xFF1E88E5);
Color lightblue = const Color(0xFF4092DB);
Color tabColor1 = const Color(0xFF1E3E5B);
Color tabColor2 = const Color(0xFF778087);
Color productColor = const Color(0xFFFD8018);


// 🌿 Primary Green Gradient (Background)
LinearGradient primaryGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF49B45F),   // primary
    Color(0xFF2E7D32),   // darker green
  ],
);

// 🌿 Soft Light Background Gradient (Optional Modern Look)
LinearGradient softPrimaryGradient = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF6EDC8A),
    Color(0xFF49B45F),
  ],
);

// 🌿 Button Gradient
LinearGradient buttonGradient = const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFF554CCD), // primary
    Color(0xFF3F37A0), // darker shade
  ],
);