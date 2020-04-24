import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedDisappear extends StatefulWidget {
  Duration duration;
  Widget child;
  bool visible;
  Curve curve;
  AnimatedDisappear(
      {Key key, this.duration, this.child, this.visible, this.curve})
      : super(key: key);

  @override
  _AnimatedDisappear createState() => _AnimatedDisappear();
}

class _AnimatedDisappear extends State<AnimatedDisappear>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animation =
        CurvedAnimation(parent: _animationController, curve: widget.curve)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            _animationStatus = status;
          });

    this.didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(AnimatedDisappear oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animation.value == 0) {
      return Container();
    }

    return Opacity(
      opacity: _animation.value,
      child: widget.child,
    );
  }
}
