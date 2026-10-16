import 'dart:async';
import 'package:flutter/material.dart';

class RepeatIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Duration initialDelay;
  final Duration repeatDelay;
  final String? tooltip;
  final Color? color;
  final double? iconSize;

  const RepeatIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.initialDelay = const Duration(milliseconds: 300),
    this.repeatDelay = const Duration(milliseconds: 50),
    this.tooltip,
    this.color,
    this.iconSize,
  });

  @override
  State<RepeatIconButton> createState() => _RepeatIconButtonState();
}

class _RepeatIconButtonState extends State<RepeatIconButton> {
  Timer? _timer;

  void _startRepeat() {
    _timer = Timer(widget.initialDelay, () {
      _timer = Timer.periodic(widget.repeatDelay, (timer) {
        widget.onPressed();
      });
    });
  }

  void _stopRepeat() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPressStart: (_) {
        Future.microtask(() => widget.onPressed());
        _startRepeat();
      },
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressUp: _stopRepeat,
      child: IconButton(
        icon: widget.icon,
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        color: widget.color,
        iconSize: widget.iconSize ?? 24.0,
      ),
    );
  }
}
