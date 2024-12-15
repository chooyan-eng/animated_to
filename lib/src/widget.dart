import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// AnimatedTo is a widget that animates a child to a new position.
/// Users of this widget don't need to calculate any animation values
/// as the calculation is always done by RenderObject.
///
/// TODO(chooyan-eng): Fix the issue that [AnimatedTo] doesn't work on
/// [Scrollable] kind of widgets.
class AnimatedTo extends SingleChildRenderObjectWidget {
  /// duration to animate the child to the new position.
  final Duration duration;

  /// curve to animate the child to the new position.
  final Curve curve;

  /// [TickerProvider] object for [AnimationController].
  final TickerProvider vsync;

  /// [child] will start animation from [appearingFrom] in the first frame.
  /// This indicates absolute position in the global coordinate system.
  final Offset? appearingFrom;

  /// [child] will start animation from [slidingFrom] in the first frame.
  /// This indicates relative position to child's intrinsic position.
  final Offset? slidingFrom;

  const AnimatedTo({
    super.key,
    super.child,
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.appearingFrom,
    this.slidingFrom,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnimatedRebuild(
      duration: duration,
      curve: curve,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAnimatedRebuild renderObject) {
    renderObject
      ..duration = duration
      ..curve = curve
      ..vsync = vsync
      ..appearingFrom = appearingFrom
      ..slidingFrom = slidingFrom;
  }
}

/// [RenderObject] implementation for [AnimatedTo].
class RenderAnimatedRebuild extends RenderProxyBox {
  RenderAnimatedRebuild({
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
  })  : _duration = duration,
        _curve = curve,
        _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom;

  Duration _duration;
  set duration(Duration value) {
    if (_duration == value) return;
    _duration = value;
  }

  Curve _curve;
  set curve(Curve value) {
    if (_curve == value) return;
    _curve = value;
  }

  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    if (_vsync == value) return;
    _vsync = value;
  }

  Offset? _appearingFrom;
  set appearingFrom(Offset? value) {
    if (_appearingFrom == value) return;
    _appearingFrom = value;
  }

  Offset? _slidingFrom;
  set slidingFrom(Offset? value) {
    if (_slidingFrom == value) return;
    _slidingFrom = value;
  }

  Offset? _oldOffset;
  Offset _targetOffset = Offset.zero;
  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void detach() {
    _controller?.removeListener(_onAnimationChanged);
    _controller?.dispose();
    _controller = null;
    super.detach();
  }

  void _onAnimationChanged() {
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // if either of _appearingFrom or _slidingFrom is given,
    // animation should be start from that position in the first frame.
    if (_oldOffset == null) {
      _oldOffset = _appearingFrom;
      _oldOffset ??= offset + (_slidingFrom ?? Offset.zero);
      _targetOffset = _oldOffset ?? offset;
    }

    // if still _oldOffset is null, meaning _appearingFrom or _slidingFrom is not given,
    // keep the first position as the next starting position.
    if (_oldOffset == null) {
      _oldOffset = offset;
      _targetOffset = offset;
    } else if (_targetOffset != offset) {
      // if the target position is different from the current position,
      // start the animation.
      _startAnimation(offset);
    }

    final animationOffset = _animation?.value ?? offset;
    context.paintChild(child!, animationOffset);
  }

  void _startAnimation(Offset newOffset) {
    _oldOffset = _animation?.value ?? _targetOffset;
    _targetOffset = newOffset;

    _controller?.dispose();
    _controller = AnimationController(
      vsync: _vsync,
      duration: _duration,
    )..addListener(_onAnimationChanged);
    _animation = _controller!
        .drive(
          CurveTween(curve: _curve),
        )
        .drive(
          Tween<Offset>(
            begin: _oldOffset,
            end: _targetOffset,
          ),
        );

    _controller!.forward();
  }
}
