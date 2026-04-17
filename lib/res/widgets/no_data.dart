import 'package:flutter/material.dart';

class NoDataIcon extends StatefulWidget {
  final double size;

  const NoDataIcon({super.key, this.size = 150.0});

  @override
  State<NoDataIcon> createState() => _NoDataIconState();
}

class _NoDataIconState extends State<NoDataIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Makes it breathe in and out

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The Image you uploaded
            Image.asset(
              'assets/gif/nodata2.png',
              width: widget.size,
              height: widget.size,
            ),
            // Optional: Adding a soft glow effect behind it
            Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}