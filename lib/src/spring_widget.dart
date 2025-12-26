import 'package:animated_to/animated_to.dart';
import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/size_maintainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:motor/motor.dart';

/// "spring" version of [AnimatedTo].
class SpringAnimatedTo extends StatefulWidget {
  const SpringAnimatedTo({
    required this.globalKey,
    required this.description,
    this.velocityBuilder,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.hitTestEnabled = true,
    this.onEnd,
    this.verticalController,
    this.horizontalController,
    this.child,
    this.sizeWidget,
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

  /// Controls whether hit testing is performed at the animated position during animation.
  ///
  /// When `true`, this widget will respond to hit tests at its current animated position
  /// while animating. When `false`, hit tests will only occur at the widget's layout position.
  ///
  /// Note: This flag only affects behavior during animation. When the widget is not animating,
  /// hit testing always occurs at the widget's normal layout position regardless of this setting.
  ///
  /// Defaults to `true`.
  final bool hitTestEnabled;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? verticalController;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView] with [Axis.horizontal].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? horizontalController;

  /// [child] to animate.
  final Widget? child;

  /// [sizeWidget] to maintain the size of the child, regardless of transformation animations.
  final Widget? sizeWidget;

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
      hitTestEnabled: widget.hitTestEnabled,
      onEnd: widget.onEnd,
      verticalController: widget.verticalController,
      horizontalController: widget.horizontalController,
      velocityBuilder: widget.velocityBuilder,
      child: RepaintBoundary(
        child: widget.sizeWidget == null
            ? widget.child
            : SizeMaintainer(
                sizeWidget: widget.sizeWidget!,
                child: widget.child!,
              ),
      ),
    );
  }
}

class _AnimatedToRenderObjectWidget extends SingleChildRenderObjectWidget {
  final TickerProvider vsync;
  final SpringDescription description;
  final Offset? appearingFrom;
  final Offset? slidingFrom;
  final bool enabled;
  final bool hitTestEnabled;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  final Offset Function()? velocityBuilder;
  const _AnimatedToRenderObjectWidget({
    super.child,
    required this.vsync,
    required this.description,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.hitTestEnabled = true,
    this.onEnd,
    this.verticalController,
    this.horizontalController,
    this.velocityBuilder,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAnimatedTo(
      description: description,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      hitTestEnabled: hitTestEnabled,
      onEnd: onEnd,
      verticalController: verticalController,
      horizontalController: horizontalController,
      velocityBuilder: velocityBuilder,
      boundary: AnimatedToBoundary.of(context),
      ancestor: context.findAncestorRenderObjectOfType<RenderAnimatedTo>(),
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
      ..hitTestEnabled = hitTestEnabled
      ..onEnd = onEnd
      ..verticalController = verticalController
      ..horizontalController = horizontalController
      ..velocityBuilder = velocityBuilder
      ..ancestor = context.findAncestorRenderObjectOfType<RenderAnimatedTo>()
      ..boundary = AnimatedToBoundary.of(context);
  }
}

/// [RenderObject] implementation for [SpringAnimatedTo].
class _RenderAnimatedTo extends RenderProxyBox implements RenderAnimatedTo {
  _RenderAnimatedTo({
    required SpringDescription description,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
    required bool enabled,
    required bool hitTestEnabled,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? verticalController,
    ScrollController? horizontalController,
    Offset Function()? velocityBuilder,
    double? verticalScrollOffset,
    double? horizontalScrollOffset,
    RenderAnimatedToBoundary? boundary,
    RenderAnimatedTo? ancestor,
  })  : _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _hitTestEnabled = hitTestEnabled,
        _onEnd = onEnd,
        _verticalController = verticalController,
        _horizontalController = horizontalController,
        _velocityBuilder = velocityBuilder,
        _verticalScrollOffset = verticalScrollOffset,
        _horizontalScrollOffset = horizontalScrollOffset,
        _boundary = boundary,
        _ancestor = ancestor {
    _controller = MotionController<Offset>(
      motion: SpringMotion(description, snapToEnd: true),
      vsync: _vsync,
      converter: MotionConverter.offset,
      initialValue: Offset.zero,
    )..addListener(_attemptPaint);

    // listen to scroll offset and update [_scrollOffset] of [_RenderAnimatedTo] when it changes.
    if (_verticalController != null) {
      _verticalController!.addListener(_verticalControllerListener);
    }
    if (_horizontalController != null) {
      _horizontalController!.addListener(_horizontalControllerListener);
    }
  }

  set description(SpringDescription value) {
    _controller.motion = SpringMotion(value, snapToEnd: true);
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

  bool _hitTestEnabled = true;
  set hitTestEnabled(bool value) {
    _hitTestEnabled = value;
  }

  /// Implementation of [RenderAnimatedTo.hitTestEnabled]
  @override
  bool get hitTestEnabled => _hitTestEnabled;

  void Function(AnimationEndCause cause)? _onEnd;
  set onEnd(void Function(AnimationEndCause cause)? value) {
    _onEnd = value;
  }

  /// This field is always updated by [controller]'s callback.
  double? _verticalScrollOffset;
  set verticalScrollOffset(double? value) {
    _verticalScrollOffset = value;
  }

  double? _horizontalScrollOffset;
  set horizontalScrollOffset(double? value) {
    _horizontalScrollOffset = value;
  }

  Offset Function()? _velocityBuilder;
  set velocityBuilder(Offset Function()? value) {
    _velocityBuilder = value;
  }

  /// current journey
  Journey? _journey;

  /// for animation
  late MotionController<Offset> _controller;

  /// for scroll management
  OffsetCache _cache = OffsetCache();

  /// Reference to the ancestor [AnimatedToBoundary]'s render object
  RenderAnimatedToBoundary? _boundary;
  set boundary(RenderAnimatedToBoundary? value) {
    _boundary = value;
  }

  /// Reference to the ancestor [RenderAnimatedTo] if any.
  RenderAnimatedTo? _ancestor;
  RenderAnimatedTo? _lastAncestor;
  set ancestor(RenderAnimatedTo? value) {
    _ancestor = value;
  }

  /// Current animated position in global coordinates
  Offset _currentAnimatedOffset = Offset.zero;

  /// Implementation of [RenderAnimatedTo.currentAnimatedOffset]
  @override
  Offset get currentAnimatedOffset => _currentAnimatedOffset;

  @override
  Offset get globalOffset => localToGlobal(
      Offset(
        _horizontalScrollOffset ?? 0,
        _verticalScrollOffset ?? 0,
      ),
      ancestor: _ancestor ?? _boundary);

  ScrollController? _verticalController;
  set verticalController(ScrollController? value) {
    // Update the listener when the controller is changed
    if (_verticalController != value) {
      // Remove the old listener
      if (_verticalController != null) {
        _verticalController!.removeListener(_verticalControllerListener);
      }

      // Register a new listener
      if (value != null) {
        value.addListener(_verticalControllerListener);
      }
    }

    _verticalController = value;
  }

  ScrollController? _horizontalController;
  set horizontalController(ScrollController? value) {
    // Update the listener when the controller is changed
    if (_horizontalController != value) {
      // Remove the old listener
      if (_horizontalController != null) {
        _horizontalController!.removeListener(_horizontalControllerListener);
      }

      // Register a new listener
      if (value != null) {
        value.addListener(_horizontalControllerListener);
      }
    }

    _horizontalController = value;
  }

  /// [offset] is the position where [child] should be painted if no animation is running.
  /// [_RenderAnimatedTo] prevents the [child] from being painted at [offset],
  /// and paints at animating position instead by calling [context.paintChild].
  ///
  /// [offset] is relative to the closest [RepaintBoundary] ancestor, while [localToGlobal]
  /// returns the position relative to the screen or the closest [AnimatedToBoundary] ancestor if any.
  @override
  void paint(PaintingContext context, Offset offset) {
    final boundaryOffset = localToGlobal(Offset.zero, ancestor: _boundary);

    final ancestorChanged = _ancestor != _lastAncestor;
    _lastAncestor = _ancestor;
    final cacheMutation = OffsetCacheMutation(
      lastOffset: offset,
      lastGlobalOffset: globalOffset,
      lastAncestorGlobalOffset: _ancestor?.globalOffset ?? Offset.zero,
      lastBoundaryOffset: boundaryOffset,
    );

    final prioriActions = switch ((_enabled, _journey == null)) {
      // if disabled, just keep the position for the next chance to animate.
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
        ),
      _ => null,
    };

    // apply mutation and return if there are any actions to apply,
    // which means it's disabled or first frame.
    if (prioriActions != null) {
      _applyMutation([cacheMutation, ...prioriActions.contextPovided(context)]);
      return;
    }

    // Animation is now active, regardless of animating right now or not.
    final animationActions = composeAnimation(
      animationValue: _controller.value,
      isAnimating: _controller.isAnimating,
      velocity: _controller.velocity,
      offset: offset,
      globalOffset: globalOffset,
      ancestorChanged: ancestorChanged,
      boundaryOffset: boundaryOffset,
      ancestorGlobalOffset: _ancestor?.globalOffset,
      cache: _cache,
    );

    _applyMutation(
        [cacheMutation, ...animationActions].contextPovided(context));
  }

  /// only method to apply mutation
  void _applyMutation(List<MutationAction> actions) {
    for (final action in actions) {
      switch (action) {
        case JourneyMutation(:final value):
          _journey = value;
        case AnimationStart(:final journey, :final velocity):
          // Register with boundary when animation starts
          if (hitTestEnabled) _boundary?.registerAnimatingWidget(this);
          _controller
              .animateTo(
            journey.to,
            from: journey.from,
            withVelocity: velocity ?? _velocityBuilder?.call(),
          )
              .then((_) {
            _applyMutation([AnimationEnd()]);
          });
        case AnimationEnd():
          // Unregister from boundary when animation ends
          _boundary?.unregisterAnimatingWidget(this);
          _onEnd?.call(AnimationEndCause.completed);
        case AnimationCancel():
          // Unregister from boundary when animation is cancelled
          _boundary?.unregisterAnimatingWidget(this);
          _onEnd?.call(AnimationEndCause.interrupted);

        case PaintChild(:final offset, :final context):
          assert(context != null, 'context is required');
          // Update current animated position in global coordinates
          _currentAnimatedOffset =
              localToGlobal(Offset.zero, ancestor: _boundary) +
                  (offset - _cache.lastOffset!);
          context!.paintChild(child!, offset);
        case OffsetCacheMutation(
            :final startOffset,
            :final lastOffset,
            :final lastGlobalOffset,
            :final lastBoundaryOffset,
            :final lastAncestorGlobalOffset,
          ):
          _cache = _cache.copyWith(
            startOffset: startOffset,
            lastOffset: lastOffset,
            lastGlobalOffset: lastGlobalOffset,
            lastBoundaryOffset: lastBoundaryOffset,
            lastAncestorGlobalOffset: lastAncestorGlobalOffset,
          );
      }
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _applyMutation([AnimationCancel()]);
    }
    _controller.removeListener(_attemptPaint);
    _controller.dispose();
    if (_verticalController != null) {
      _verticalController!.removeListener(_verticalControllerListener);
      _verticalController = null;
    }
    if (_horizontalController != null) {
      _horizontalController!.removeListener(_horizontalControllerListener);
      _horizontalController = null;
    }
    _boundary?.unregisterAnimatingWidget(this);
    super.dispose();
  }

  /// attempt [markNeedsPaint] if [owner] is not operating in [paint] phase.
  void _attemptPaint() {
    if (owner?.debugDoingPaint != true) {
      markNeedsPaint();
    }
  }

  void _verticalControllerListener() {
    if (_verticalController != null) {
      _verticalScrollOffset = _verticalController!.offset;
    }
  }

  void _horizontalControllerListener() {
    if (_horizontalController != null) {
      _horizontalScrollOffset = _horizontalController!.offset;
    }
  }
}
