import 'package:flutter/material.dart';
import 'package:uppo/main.dart';

class ControlledAnimatedPositioned extends StatefulWidget {
  ControlledAnimatedPositioned(
      {Key key,
      @required this.child,
      @required this.start,
      @required this.end,
      @required this.duration,
      this.disposeOnCompleted = false})
      : super(key: key);

  final Widget child;
  final Offset start;
  final Offset end;
  final Duration duration;
  final bool disposeOnCompleted;

  @override
  _ControlledAnimatedPositioned createState() =>
      _ControlledAnimatedPositioned();
}

class _ControlledAnimatedPositioned extends State<ControlledAnimatedPositioned>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> top;
  Animation<double> left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left.value,
      top: top.value,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);

    final Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCirc);

    left = Tween(begin: widget.start.dx, end: widget.end.dx).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    top = Tween(begin: widget.start.dy, end: widget.end.dy).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
