import 'dart:async';
import 'package:flutter/material.dart';


class MarqueeList extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double speed;

  const MarqueeList({
    super.key,
    required this.child,
    required this.controller,
    this.speed = 3.0,
  });

  @override
  State<MarqueeList> createState() => _MarqueeListState();
}

class _MarqueeListState extends State<MarqueeList> {
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || !widget.controller.hasClients || _isUserInteracting) return;

      double maxScroll = widget.controller.position.maxScrollExtent;
      double currentScroll = widget.controller.offset;

      // Stop scrolling if reached bottom
      if (currentScroll < maxScroll) {
        widget.controller.animateTo(
          currentScroll + widget.speed,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      } else {
        //Cancel timer if reached end
        timer.cancel();
      }
    });
  }

  void _handleUserInteraction() {
    setState(() => _isUserInteracting = true);
    _resumeTimer?.cancel();

    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isUserInteracting = false);
        _startAutoScroll(); // Restart the timer loop
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleUserInteraction(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
            _handleUserInteraction();
          }
          return false;
        },
        child: widget.child,
      ),
    );
  }
}