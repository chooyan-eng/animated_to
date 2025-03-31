import 'package:animated_to/animated_to.dart';
import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/size_maintainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

/// "burst" version of [AnimatedTo].
class BurstAnimatedTo extends StatefulWidget {
  const BurstAnimatedTo({
    required this.globalKey,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.child,
    this.sizeWidget,
  }) : super(key: globalKey);

  /// [GlobalKey] to keep the widget alive even if its position or depth in the widget tree is changed.
  final GlobalKey globalKey;

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
  State<BurstAnimatedTo> createState() => _BurstAnimatedToState();
}

class _BurstAnimatedToState extends State<BurstAnimatedTo>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _AnimatedToRenderObjectWidget(
      vsync: this,
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
}

class _AnimatedToRenderObjectWidget extends SingleChildRenderObjectWidget {
  final TickerProvider vsync;
  final bool enabled;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? controller;
  const _AnimatedToRenderObjectWidget({
    super.child,
    required this.vsync,
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
      vsync: vsync,
      enabled: enabled,
      onEnd: onEnd,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAnimatedTo renderObject) {
    renderObject
      ..vsync = vsync
      ..enabled = enabled
      ..onEnd = onEnd;
  }
}

/// [RenderObject] implementation for [BurstAnimatedTo].
class _RenderAnimatedTo extends RenderProxyBox {
  _RenderAnimatedTo({
    required TickerProvider vsync,
    required bool enabled,
    void Function(AnimationEndCause cause)? onEnd,
    double? scrollOffset,
  })  : _vsync = vsync,
        _enabled = enabled,
        _onEnd = onEnd,
        _scrollOffset = scrollOffset {
    _controllerX = AnimationController.unbounded(
      vsync: _vsync,
    )..addListener(markNeedsPaint);
    _controllerY = AnimationController.unbounded(
      vsync: _vsync,
    )..addListener(markNeedsPaint);
  }

  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    _vsync = value;
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
  late AnimationController _controllerX;
  late AnimationController _controllerY;

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
    final prioriActions = _enabled && !_journey.isPreparing
        ? <MutationAction>[]
        : composeDisabled(
            _controllerX.isAnimating,
            offset,
          );
    // apply mutation and return if there are any actions to apply,
    // which means it's disabled or first frame.
    if (prioriActions.isNotEmpty) {
      _applyMutation(prioriActions.provided(context));
      return;
    }
    // if disabled, just keep the position for the next chance to animate.
    // Animation is now active, regardless of animating right now or not.
    final animationActions = composeBurstAnimation(
      _controllerX,
      _controllerY,
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
          _controllerX
              .animateWith(
                  FrictionSimulation(0.5, journey.from.dx, velocity?.$1 ?? 0))
              .then((_) {
            _applyMutation([AnimationEnd()]);
          });
          _controllerY
              .animateWith(GravitySimulation(
                  4000, journey.from.dy, 30000, velocity?.$2 ?? 0))
              .then((_) {
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
    if (_controllerX.isAnimating) {
      _applyMutation([AnimationCancel()]);
    }
    _controllerX.removeListener(markNeedsPaint);
    _controllerX.dispose();
    _controllerY.removeListener(markNeedsPaint);
    _controllerY.dispose();
    super.dispose();
  }
}
