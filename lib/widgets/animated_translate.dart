import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedTranslate extends StatefulWidget {
  Duration duration;
  Widget child;
  Offset offset;
  Curve curve;
  AnimatedTranslate(
      {Key key, this.duration, this.child, this.offset, this.curve})
      : super(key: key);

  @override
  _AnimatedTranslate createState() => _AnimatedTranslate();
}

class _AnimatedTranslate extends State<AnimatedTranslate>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  Offset origin;
  Offset offset;

  @override
  void initState() {
    super.initState();

    if (this.origin == null) {
      this.origin = widget.offset;
    }

    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animation =
        CurvedAnimation(parent: _animationController, curve: widget.curve)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedTranslate oldWidget) {
    super.didUpdateWidget(oldWidget);

    origin = offset;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    offset = origin + (widget.offset - origin) * _animation.value;
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }
}
