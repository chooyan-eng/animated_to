import 'package:animated_to/src/journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum AnimationEndCause {
  /// animation is interrupted by another animation
  interrupted,

  /// widget achieves its goal
  completed,
}

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

  /// Whether the animation is enabled.
  final bool enabled;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  const AnimatedTo({
    super.key,
    super.child,
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnimatedRebuild(
      duration: duration,
      curve: curve,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      onEnd: onEnd,
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
      ..slidingFrom = slidingFrom
      ..enabled = enabled
      ..onEnd = onEnd;
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
    required bool enabled,
    void Function(AnimationEndCause cause)? onEnd,
  })  : _duration = duration,
        _curve = curve,
        _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _onEnd = onEnd;

  Duration _duration;
  set duration(Duration value) {
    _duration = value;
  }

  Curve _curve;
  set curve(Curve value) {
    _curve = value;
  }

  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    _vsync = value;
  }

  Offset? _appearingFrom;
  set appearingFrom(Offset? value) {
    _appearingFrom = value;
  }

  Offset? _slidingFrom;
  set slidingFrom(Offset? value) {
    _slidingFrom = value;
  }

  bool _enabled = true;
  set enabled(bool value) {
    _enabled = value;
  }

  void Function(AnimationEndCause cause)? _onEnd;
  set onEnd(void Function(AnimationEndCause cause)? value) {
    _onEnd = value;
  }

  /// current journey
  var _journey = Journey.tighten(Offset.zero);

  /// for animation
  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void detach() {
    _stopAnimation();
    super.detach();
  }

  /// start animation with given [journey]
  void _startAnimation(Journey journey) {
    _stopAnimation();

    _controller = AnimationController(
      vsync: _vsync,
      duration: _duration,
    )..addListener(markNeedsPaint);

    _animation = _controller!
        .drive(
          CurveTween(curve: _curve),
        )
        .drive(
          Tween<Offset>(
            begin: journey.from,
            end: journey.to,
          ),
        );

    _controller!.forward().then((_) {
      _onEnd?.call(AnimationEndCause.completed);
    });
  }

  /// stop animation and dispose everything
  void _stopAnimation() {
    if (_controller?.isAnimating == true) {
      _onEnd?.call(AnimationEndCause.interrupted);
    }
    _controller?.removeListener(markNeedsPaint);
    _controller?.dispose();
    _controller = null;
    _animation = null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_enabled) {
      _stopAnimation();
      _journey = Journey.tighten(offset);
      context.paintChild(child!, offset);
      return;
    }

    // if either of _appearingFrom or _slidingFrom is given,
    // animation should be start from that position in the first frame.
    if (_journey.isPreparing) {
      final from = _appearingFrom ?? offset + (_slidingFrom ?? Offset.zero);
      _journey = Journey(from: from, to: offset);
      if (!_journey.isTightened) {
        _startAnimation(_journey);
        return;
      }
    }

    if (_journey.to != offset) {
      // start animation if the position changed
      // start from current position if still animating
      _journey = Journey(
        from: _animation?.value ?? _journey.to,
        to: offset,
      );
      _startAnimation(_journey);
    }

    // update position with animating value
    final animationOffset = _animation?.value ?? offset;
    context.paintChild(child!, animationOffset);
  }
}
