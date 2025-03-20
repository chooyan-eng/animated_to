import 'package:animated_to/animated_to.dart';
import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/let.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:springster/springster.dart';

/// "spring" version of [AnimatedTo].
class SpringAnimatedTo extends StatefulWidget {
  const SpringAnimatedTo({
    required this.globalKey,
    required this.description,
    this.velocityBuilder,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.child,
  }) : super(key: globalKey);

  /// [GlobalKey] to keep the widget alive even if its position or depth in the widget tree is changed.
  final GlobalKey globalKey;

  /// [SpringDescription] to animate the child to the new position.
  final SpringDescription description;

  /// A function that provides [Offset] of velocity to animate the child to the new position.
  /// This function is called every time [SpringAnimatedTo] decides to start animation without previous animation's velocity.
  final Offset Function()? velocityBuilder;

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

  @override
  State<SpringAnimatedTo> createState() => _SpringAnimatedToState();
}

class _SpringAnimatedToState extends State<SpringAnimatedTo>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _AnimatedToRenderObjectWidget(
      vsync: this,
      description: widget.description,
      appearingFrom: widget.appearingFrom,
      slidingFrom: widget.slidingFrom,
      enabled: widget.enabled,
      onEnd: widget.onEnd,
      controller: widget.controller,
      child: widget.child,
      velocityBuilder: widget.velocityBuilder,
    );
  }
}

class _AnimatedToRenderObjectWidget extends SingleChildRenderObjectWidget {
  final TickerProvider vsync;
  final SpringDescription description;
  final Offset? appearingFrom;
  final Offset? slidingFrom;
  final bool enabled;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? controller;
  final Offset Function()? velocityBuilder;
  const _AnimatedToRenderObjectWidget({
    super.child,
    required this.vsync,
    this.description = Spring.defaultIOS,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.velocityBuilder,
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
      description: description,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      onEnd: onEnd,
      velocityBuilder: velocityBuilder,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAnimatedTo renderObject) {
    renderObject
      ..description = description
      ..vsync = vsync
      ..appearingFrom = appearingFrom
      ..slidingFrom = slidingFrom
      ..enabled = enabled
      ..onEnd = onEnd
      ..velocityBuilder = velocityBuilder;
  }
}

/// [RenderObject] implementation for [SpringAnimatedTo].
class _RenderAnimatedTo extends RenderProxyBox {
  _RenderAnimatedTo({
    required SpringDescription description,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
    required bool enabled,
    void Function(AnimationEndCause cause)? onEnd,
    Offset Function()? velocityBuilder,
    double? scrollOffset,
  })  : _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _onEnd = onEnd,
        _velocityBuilder = velocityBuilder,
        _scrollOffset = scrollOffset {
    _controller = SpringSimulationController2D.unbounded(
      vsync: _vsync,
      spring: description,
    )..addListener(markNeedsPaint);
  }

  set description(SpringDescription value) {
    _controller.spring = value;
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

  Offset Function()? _velocityBuilder;
  set velocityBuilder(Offset Function()? value) {
    _velocityBuilder = value;
  }

  /// current journey
  var _journey = Journey.tighten(Offset.zero);

  /// for animation
  late SpringSimulationController2D _controller;

  /// for scroll management
  OffsetCache _cache = OffsetCache();

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
          _controller.isAnimating,
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
    final animationActions = composeSpringAnimation(
      _controller,
      offset,
      _scrollOffset,
      _journey,
      _cache,
    );

    _applyMutation(animationActions.provided(context));
  }

  /// only method to apply mutation
  void _applyMutation(List<MutationAction> actions) {
    for (final action in actions) {
      switch (action) {
        case JourneyMutation(:final value):
          _journey = value;
        case AnimationStart(:final journey, :final velocity):
          _controller.animateTo(
            (journey.to.dx, journey.to.dy),
            from: (journey.from.dx, journey.from.dy),
            withVelocity: velocity ??
                _velocityBuilder?.call().let((it) => (it.dx, it.dy)),
          ).then((_) {
            _applyMutation([AnimationEnd()]);
          });
        case AnimationEnd():
          _onEnd?.call(AnimationEndCause.completed);
        case AnimationCancel():
          _onEnd?.call(AnimationEndCause.interrupted);
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
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _applyMutation([AnimationCancel()]);
    }
    _controller.removeListener(markNeedsPaint);
    _controller.dispose();
    super.dispose();
  }
}
