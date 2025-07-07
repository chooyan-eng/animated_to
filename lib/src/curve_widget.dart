import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/size_maintainer.dart';
import 'package:animated_to/src/widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CurveAnimatedTo extends StatefulWidget {
  const CurveAnimatedTo({
    required this.globalKey,
    this.duration,
    this.curve,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.child,
    this.sizeWidget,
  }) : super(key: globalKey);

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

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? controller;

  /// [child] to animate.
  final Widget? child;

  /// [sizeWidget] to maintain the size of the child, regardless of transformation animations.
  final Widget? sizeWidget;

  @override
  State<CurveAnimatedTo> createState() => _CurveAnimatedToState();
}

class _CurveAnimatedToState extends State<CurveAnimatedTo>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => _AnimatedToRenderObjectWidget(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 300),
        curve: widget.curve ?? Curves.easeInOut,
        appearingFrom: widget.appearingFrom,
        slidingFrom: widget.slidingFrom,
        enabled: widget.enabled,
        onEnd: widget.onEnd,
        controller: widget.controller,
        child: widget.sizeWidget == null
            ? widget.child
            : SizeMaintainer(
                sizeWidget: widget.sizeWidget!,
                child: widget.child!,
              ),
      );
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

/// [RenderObject] implementation for [CurveAnimatedTo].
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

  /// cache of [Offset]s for calculation
  var _cache = OffsetCache();

  /// a flag to indicate the [paint] phase is right after [layout] phase.
  bool _dirtyLayout = false;

  /// to distinguish the [offset] updates in [paint] phase is caused by [layout] or not,
  /// especially during scrolling, [_dirtyLayout] is set true when [layout] is called.
  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    _dirtyLayout = true;
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  /// [offset] is the position where [child] should be painted if no animation is running.
  /// [_RenderAnimatedTo] prevents the [child] from being painted at [offset],
  /// and paints at animating position instead by calling [context.paintChild].
  ///
  /// note that [offset] also changes when scrolling on [SingleChildScrollView].
  @override
  void paint(PaintingContext context, Offset offset) {
    // if disabled, just keep the position for the next chance to animate.
    final prioriActions = switch ((_enabled, _journey.isPreparing)) {
      (false, _) => composeDisabled(
          _controller?.isAnimating,
          offset,
        ),
      // if either of [_appearingFrom] or [_slidingFrom] is given,
      // animation should be start from that position in the first frame.
      (_, true) => composeFirstFrame(
          _appearingFrom,
          _slidingFrom,
          offset,
          _scrollOffset ?? 0.0,
        ),
      _ => null,
    };

    // apply mutation and return if there are any actions to apply,
    // which means it's disabled or first frame.
    if (prioriActions != null) {
      _applyMutation(prioriActions.provided(context));
      return;
    }

    // Animation is now active, regardless of animating right now or not.
    final animationActions = composeAnimation(
      _controller,
      _animation?.value,
      offset,
      _scrollOffset,
      _journey,
      _cache,
      _dirtyLayout,
    );

    _applyMutation(animationActions.provided(context));
  }

  /// only method to apply mutation
  void _applyMutation(List<MutationAction> actions) {
    for (final action in actions) {
      switch (action) {
        case JourneyMutation(:final value):
          _journey = value;
        case AnimationStart(:final journey):
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
            _applyMutation([AnimationEnd()]);
          });
        case AnimationEnd():
          _onEnd?.call(AnimationEndCause.completed);
          _controller?.removeListener(markNeedsPaint);
          _controller?.dispose();
          _controller = null;
          _animation = null;
        case AnimationCancel():
          _onEnd?.call(AnimationEndCause.interrupted);
          _controller?.removeListener(markNeedsPaint);
          _controller?.dispose();
          _controller = null;
          _animation = null;
        case PaintChild(:final offset, :final context):
          assert(context != null, 'context is required');
          context!.paintChild(child!, offset);
        case OffsetCacheMutation(
            scroll: final scrollOffset,
            scrollOriginal: final scrollOriginal,
            last: final lastOffset
          ):
          _cache = _cache.copyWith(
            scrollLast: scrollOffset,
            scrollOriginal: scrollOriginal,
            last: lastOffset,
          );
      }
    }
    _dirtyLayout = false;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _applyMutation(
        [_controller!.isAnimating ? AnimationCancel() : AnimationEnd()],
      );
    }
    super.dispose();
  }
}
