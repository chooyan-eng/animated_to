import 'package:animated_to/src/journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:springster/springster.dart';

/// Cause of animation end.
enum AnimationEndCause {
  /// animation is interrupted by another animation
  interrupted,

  /// widget achieves its goal
  completed,
}

/// [AnimatedTo] is a widget that animates a given [child] when its position changes for any reason.
/// You don't need to calculate any animation values, as the calculation is always done by [RenderObject].
///
/// Example:
/// ```dart
/// final widget = AnimatedTo(
///   globalKey: GlobalObjectKey(item),
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// );
///
/// // if _horizontal is true, the widget is in Row.
/// // otherwise, the widget is in Column.
/// return _horizontal ? Row(children: [widget, widget])
///   : Column(children: [widget, widget]);
/// ```
///
/// In the example above, the widget is automatically animated when _horizontal is changed and rebuilt.
///
/// Because [AnimatedTo] need to be kept alive even if its position or depth in the widget tree is changed,
/// [GlobalKey] must be provided to avoid the Flutter framework from disposing of it.
class AnimatedTo extends StatefulWidget {
  const AnimatedTo({
    required this.globalKey,
    this.duration,
    this.curve,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.child,
  })  : spring = null,
        super(key: globalKey);

  const AnimatedTo.usingSpring({
    required this.globalKey,
    this.spring,
    this.enabled = true,
    this.appearingFrom,
    this.slidingFrom,
    this.onEnd,
    this.controller,
    this.child,
  })  : duration = null,
        curve = null,
        super(key: globalKey);

  /// [GlobalKey] to keep the widget alive even if its position or depth in the widget tree is changed.
  final GlobalKey globalKey;

  /// [Duration] to animate the child to the new position.
  final Duration? duration;

  /// [Curve] to animate the child to the new position.
  final Curve? curve;

  /// If [appearingFrom] is given, [child] will start animation from [appearingFrom] in the first frame.
  /// This indicates absolute position in the global coordinate system.
  final Offset? appearingFrom;

  /// If [slidingFrom] is given, [child] will start animation from [slidingFrom] in the first frame.
  /// This indicates relative position to child's intrinsic position.
  final Offset? slidingFrom;

  /// Whether the animation is enabled.
  /// If false, the [child] will update its position without animation.
  final bool enabled;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  final Spring? spring;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? controller;

  /// [child] to animate.
  final Widget? child;

  @override
  State<AnimatedTo> createState() => _AnimatedToState();
}

class _AnimatedToState extends State<AnimatedTo> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.spring != null) {
      return _AnimatedToSpringRenderObjectWidget(
        vsync: this,
        spring: widget.spring!,
        appearingFrom: widget.appearingFrom,
        slidingFrom: widget.slidingFrom,
        enabled: widget.enabled,
        onEnd: widget.onEnd,
        controller: widget.controller,
        child: widget.child,
      );
    }

    return _AnimatedToRenderObjectWidget(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 300),
      curve: widget.curve ?? Curves.easeInOut,
      appearingFrom: widget.appearingFrom,
      slidingFrom: widget.slidingFrom,
      enabled: widget.enabled,
      onEnd: widget.onEnd,
      controller: widget.controller,
      child: widget.child,
    );
  }
}

class _AnimatedToRenderObjectWidget extends SingleChildRenderObjectWidget {
  final Duration duration;
  final Curve curve;
  final TickerProvider vsync;
  final Offset? appearingFrom;
  final Offset? slidingFrom;
  final bool enabled;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? controller;

  const _AnimatedToRenderObjectWidget({
    super.child,
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    // listen to scroll offset and update [_scrollOffset] of [_RenderAnimatedTo] when it changes.
    controller?.addListener(() {
      final renderObject = context.findRenderObject();
      if (renderObject is _RenderAnimatedTo) {
        renderObject.scrollOffset = controller!.offset;
      }
    });
    return _RenderAnimatedTo(
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
      BuildContext context, _RenderAnimatedTo renderObject) {
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
class _RenderAnimatedTo extends RenderProxyBox {
  _RenderAnimatedTo({
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
    required bool enabled,
    void Function(AnimationEndCause cause)? onEnd,
    double? scrollOffset,
  })  : _duration = duration,
        _curve = curve,
        _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _onEnd = onEnd,
        _scrollOffset = scrollOffset;

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

  /// This field is always updated by [controller]'s callback.
  double? _scrollOffset;
  set scrollOffset(double? value) {
    _scrollOffset = value;
  }

  /// current journey
  var _journey = Journey.tighten(Offset.zero);

  /// for animation
  AnimationController? _controller;
  Animation<Offset>? _animation;

  /// for scroll management
  double? _scrollOffsetCache;
  double? _scrollOffsetWhenAnimationStarted;
  Offset? _lastOffset;

  /// start animation with given [journey]
  void _startAnimation(Journey journey) {
    _stopAnimation();

    _controller = AnimationController(
      vsync: _vsync,
      duration: _duration,
    );

    _controller?.duration = _duration;
    _controller!.addListener(markNeedsPaint);

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
      _stopAnimation();
    });
    _scrollOffsetWhenAnimationStarted = _scrollOffset ?? 0.0;
  }

  /// stop animation and dispose everything
  void _stopAnimation() {
    if (_controller == null) return;
    if (_controller?.isAnimating == true) {
      _onEnd?.call(AnimationEndCause.interrupted);
    } else {
      _onEnd?.call(AnimationEndCause.completed);
    }
    _controller?.removeListener(markNeedsPaint);
    _controller?.dispose();
    _controller = null;
    _animation = null;
    _scrollOffsetWhenAnimationStarted = null;
  }

  /// [offset] is the position where [child] should be painted if no animation is running.
  /// [_RenderAnimatedTo] prevents the [child] from being painted at [offset],
  /// and paints at animating position instead by calling [context.paintChild].
  ///
  /// note that [offset] also changes when scrolling on [SingleChildScrollView].
  @override
  void paint(PaintingContext context, Offset offset) {
    // if disabled, just keep the position for the next chance to animate.
    if (!_enabled) {
      _stopAnimation();
      _journey = Journey.tighten(offset);
      super.paint(context, offset);
      return;
    }

    // only in the first frame
    if (_journey.isPreparing) {
      // if neither of [_appearingFrom] or [_slidingFrom] is given,
      // just render [child] with the default operation.
      if (_appearingFrom == null && _slidingFrom == null) {
        _journey = Journey.tighten(offset);
        super.paint(context, offset);
        return;
      }

      // if either of [_appearingFrom] or [_slidingFrom] is given,
      // animation should be start from that position in the first frame.
      _journey = Journey(
        from: _appearingFrom ?? offset + _slidingFrom!,
        to: offset,
      );
      _startAnimation(_journey);
      return;
    }

    final lastOffset = _lastOffset;
    _lastOffset = offset;

    final isAnimating = _controller?.isAnimating == true;
    final isScrolling = _scrollOffsetCache != _scrollOffset;

    if (isScrolling) {
      if (!isAnimating) {
        // scrolling, but not animating
        final scrollGap = (_scrollOffsetCache ?? 0.0) - _scrollOffset!;
        final positionGap = offset - (lastOffset ?? offset);
        // TODO(chooyan-eng): Because we can't tell [position] is updated because of scrolling or rebuilding,
        // less than 40 is a magic number to estimate the position is updated because of scrolling.
        if ((scrollGap - positionGap.distance).abs() > 40) {
          // scrolling but also position updated
          _journey = Journey(
            from: _journey.to,
            to: offset,
          );
          _startAnimation(_journey);
        } else {
          // just scroll by user
          _scrollOffsetCache = _scrollOffset;
          _journey = Journey.tighten(offset);
          super.paint(context, offset);
          return;
        }
      }

      // cache scroll offset and position considering scroll gap
      // regardless of whether animating now or not.
      _scrollOffsetCache = _scrollOffset;
      _journey = Journey.tighten(offset);
    } else {
      if (isAnimating) {
        // not scrolling, but animating
        if (_journey.to != offset) {
          // if [position] is updated during animation,
          // start another animation from current position
          _journey = Journey(
            from: _animation!.value -
                Offset(
                  0,
                  (_scrollOffset ?? 0) -
                      (_scrollOffsetWhenAnimationStarted ?? 0),
                ),
            to: offset,
          );
          _startAnimation(_journey);
        }
      } else {
        // not scrolling, not animating either
        if (_journey.to != offset) {
          // start animation if the position changed
          _journey = Journey(
            from: _journey.to,
            to: offset,
          );
          _startAnimation(_journey);
        }
      }
    }

    if (_animation != null) {
      final scrollGap = _scrollOffset == null
          ? 0.0
          : _scrollOffsetWhenAnimationStarted! - (_scrollOffset ?? 0.0);
      final animationOffset = _animation!.value + Offset(0, scrollGap);
      context.paintChild(child!, animationOffset);
    } else {
      context.paintChild(child!, offset);
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    super.dispose();
  }
}

class _AnimatedToSpringRenderObjectWidget
    extends SingleChildRenderObjectWidget {
  final Spring spring;
  final TickerProvider vsync;
  final Offset? appearingFrom;
  final Offset? slidingFrom;
  final bool enabled;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? controller;

  const _AnimatedToSpringRenderObjectWidget({
    super.child,
    required this.spring,
    required this.vsync,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    // listen to scroll offset and update [_scrollOffset] of [_RenderAnimatedTo] when it changes.
    controller?.addListener(() {
      final renderObject = context.findRenderObject();
      if (renderObject is _RenderAnimatedToSpring) {
        renderObject.scrollOffset = controller!.offset;
      }
    });
    return _RenderAnimatedToSpring(
      spring: spring,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      onEnd: onEnd,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAnimatedToSpring renderObject) {
    renderObject
      ..spring = spring
      ..vsync = vsync
      ..appearingFrom = appearingFrom
      ..slidingFrom = slidingFrom
      ..enabled = enabled
      ..onEnd = onEnd;
  }
}

/// [RenderObject] implementation for [AnimatedTo].
class _RenderAnimatedToSpring extends RenderProxyBox {
  _RenderAnimatedToSpring({
    required Spring spring,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
    required bool enabled,
    void Function(AnimationEndCause cause)? onEnd,
    double? scrollOffset,
  })  : _spring = spring,
        _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _onEnd = onEnd,
        _scrollOffset = scrollOffset {
    _controller = SpringSimulationController2D.unbounded(
      vsync: _vsync,
      spring: _spring,
    );
  }

  Spring _spring;
  set spring(Spring value) {
    _spring = value;
    _controller.spring = value;
  }

  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    _vsync = value;
    _controller.resync(value);
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

  /// This field is always updated by [controller]'s callback.
  double? _scrollOffset;
  set scrollOffset(double? value) {
    _scrollOffset = value;
  }

  /// current journey
  var _journey = Journey.tighten(Offset.zero);

  /// for animation
  late final SpringSimulationController2D _controller;

  /// for scroll management
  double? _scrollOffsetCache;
  double? _scrollOffsetWhenAnimationStarted;
  Offset? _lastOffset;

  /// start animation with given [journey]
  void _startAnimation(Journey journey) {
    _controller.addListener(markNeedsPaint);
    _controller.animateTo(
      (journey.to.dx, journey.to.dy),
    ).then((_) {
      _stopAnimation();
    });
    _scrollOffsetWhenAnimationStarted = _scrollOffset ?? 0.0;
  }

  /// stop animation and dispose everything
  void _stopAnimation() {
    if (_controller.isAnimating == true) {
      _onEnd?.call(AnimationEndCause.interrupted);
    } else {
      _onEnd?.call(AnimationEndCause.completed);
    }
    _controller.removeListener(markNeedsPaint);
    _scrollOffsetWhenAnimationStarted = null;
  }

  /// [offset] is the position where [child] should be painted if no animation is running.
  /// [_RenderAnimatedTo] prevents the [child] from being painted at [offset],
  /// and paints at animating position instead by calling [context.paintChild].
  ///
  /// note that [offset] also changes when scrolling on [SingleChildScrollView].
  @override
  void paint(PaintingContext context, Offset offset) {
    // if disabled, just keep the position for the next chance to animate.
    if (!_enabled) {
      _stopAnimation();
      _journey = Journey.tighten(offset);
      super.paint(context, offset);
      return;
    }

    // only in the first frame
    if (_journey.isPreparing) {
      // if neither of [_appearingFrom] or [_slidingFrom] is given,
      // just render [child] with the default operation.
      if (_appearingFrom == null && _slidingFrom == null) {
        _journey = Journey.tighten(offset);
        _controller.value = (offset.dx, offset.dy);
        super.paint(context, offset);
        return;
      }

      // if either of [_appearingFrom] or [_slidingFrom] is given,
      // animation should be start from that position in the first frame.
      _journey = Journey(
        from: _appearingFrom ?? offset + _slidingFrom!,
        to: offset,
      );
      _controller.value = (_journey.from.dx, _journey.from.dy);
      _startAnimation(_journey);
      return;
    }

    final lastOffset = _lastOffset;
    _lastOffset = offset;

    final isAnimating = _controller.isAnimating == true;
    final isScrolling = _scrollOffsetCache != _scrollOffset;

    if (isScrolling) {
      if (!isAnimating) {
        // scrolling, but not animating
        final scrollGap = (_scrollOffsetCache ?? 0.0) - _scrollOffset!;
        final positionGap = offset - (lastOffset ?? offset);
        // TODO(chooyan-eng): Because we can't tell [position] is updated because of scrolling or rebuilding,
        // less than 40 is a magic number to estimate the position is updated because of scrolling.
        if ((scrollGap - positionGap.distance).abs() > 40) {
          // scrolling but also position updated
          _journey = Journey(
            from: _journey.to,
            to: offset,
          );
          _startAnimation(_journey);
        } else {
          // just scroll by user
          _scrollOffsetCache = _scrollOffset;
          _journey = Journey.tighten(offset);
          super.paint(context, offset);
          return;
        }
      }

      // cache scroll offset and position considering scroll gap
      // regardless of whether animating now or not.
      _scrollOffsetCache = _scrollOffset;
      _journey = Journey.tighten(offset);
    } else {
      if (isAnimating) {
        // not scrolling, but animating
        if (_journey.to != offset) {
          // if [position] is updated during animation,
          // start another animation from current position
          _journey = Journey(
            from: _controller.value.toOffset() -
                Offset(
                  0,
                  (_scrollOffset ?? 0) -
                      (_scrollOffsetWhenAnimationStarted ?? 0),
                ),
            to: offset,
          );
          _startAnimation(_journey);
        }
      } else {
        // not scrolling, not animating either
        if (_journey.to != offset) {
          // start animation if the position changed
          _journey = Journey(
            from: _journey.to,
            to: offset,
          );
          _startAnimation(_journey);
        }
      }
    }

    final scrollGap = _scrollOffset == null
        ? 0.0
        : _scrollOffsetWhenAnimationStarted! - (_scrollOffset ?? 0.0);
    final animationOffset = _controller.value.toOffset() + Offset(0, scrollGap);
    context.paintChild(child!, animationOffset);
  }

  @override
  void dispose() {
    _stopAnimation();
    _controller.dispose();
    super.dispose();
  }
}
