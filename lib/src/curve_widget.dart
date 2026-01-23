import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/animated_to_boundary.dart';
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
    this.hitTestEnabled = true,
    this.hitTestOverflow = false,
    this.onEnd,
    this.verticalController,
    this.horizontalController,
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

  /// When true, allows hit testing outside this render object's layout bounds.
  ///
  /// This is useful when a descendant transform paints outside its original
  /// bounds (e.g., rotation) and you want taps to be detected on the visual
  /// area rather than the untransformed layout box.
  ///
  /// Defaults to `false`.
  final bool hitTestOverflow;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView] with [Axis.vertical].
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
        hitTestEnabled: widget.hitTestEnabled,
        hitTestOverflow: widget.hitTestOverflow,
        onEnd: widget.onEnd,
        verticalController: widget.verticalController,
        horizontalController: widget.horizontalController,
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

class _AnimatedToRenderObjectWidget extends SingleChildRenderObjectWidget {
  final Duration duration;
  final Curve curve;
  final TickerProvider vsync;
  final Offset? appearingFrom;
  final Offset? slidingFrom;
  final bool enabled;
  final bool hitTestEnabled;
  final bool hitTestOverflow;
  final void Function(AnimationEndCause cause)? onEnd;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;

  const _AnimatedToRenderObjectWidget({
    super.child,
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.hitTestEnabled = true,
    this.hitTestOverflow = false,
    this.onEnd,
    this.verticalController,
    this.horizontalController,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAnimatedTo(
      duration: duration,
      curve: curve,
      vsync: vsync,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      hitTestEnabled: hitTestEnabled,
      hitTestOverflow: hitTestOverflow,
      onEnd: onEnd,
      verticalController: verticalController,
      horizontalController: horizontalController,
      boundary: AnimatedToBoundary.of(context),
      ancestor: context.findAncestorRenderObjectOfType<RenderAnimatedTo>(),
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
      ..hitTestEnabled = hitTestEnabled
      ..hitTestOverflow = hitTestOverflow
      ..onEnd = onEnd
      ..verticalController = verticalController
      ..horizontalController = horizontalController
      ..boundary = AnimatedToBoundary.of(context)
      ..ancestor = context.findAncestorRenderObjectOfType<RenderAnimatedTo>();
  }
}

/// [RenderObject] implementation for [CurveAnimatedTo].
class _RenderAnimatedTo extends RenderProxyBox implements RenderAnimatedTo {
  _RenderAnimatedTo({
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    Offset? appearingFrom,
    Offset? slidingFrom,
    required bool enabled,
    required bool hitTestEnabled,
    required bool hitTestOverflow,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? verticalController,
    ScrollController? horizontalController,
    RenderAnimatedToBoundary? boundary,
    RenderAnimatedTo? ancestor,
  })  : _duration = duration,
        _curve = curve,
        _vsync = vsync,
        _appearingFrom = appearingFrom,
        _slidingFrom = slidingFrom,
        _enabled = enabled,
        _hitTestEnabled = hitTestEnabled,
        _hitTestOverflow = hitTestOverflow,
        _onEnd = onEnd,
        _verticalController = verticalController,
        _horizontalController = horizontalController,
        _boundary = boundary,
        _ancestor = ancestor {
    // listen to scroll offset and update [_scrollOffset] of [_RenderAnimatedTo] when it changes.
    if (verticalController != null) {
      verticalController.addListener(_verticalControllerListener);
    }
    if (horizontalController != null) {
      horizontalController.addListener(_horizontalControllerListener);
    }
  }

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

  bool _hitTestEnabled = true;
  set hitTestEnabled(bool value) {
    _hitTestEnabled = value;
  }

  bool _hitTestOverflow = false;
  set hitTestOverflow(bool value) {
    _hitTestOverflow = value;
  }

  /// Implementation of [RenderAnimatedTo.hitTestEnabled]
  @override
  bool get hitTestEnabled => _hitTestEnabled;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_hitTestOverflow) {
      return super.hitTest(result, position: position);
    }
    // Allow hit testing outside our layout bounds when overflow is enabled.
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!_hitTestOverflow || child == null) {
      return super.hitTestChildren(result, position: position);
    }
    final transform = child!.getTransformTo(this);
    return result.addWithPaintTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset? transformed) {
        if (transformed == null) return false;
        // ignore: invalid_use_of_protected_member
        return child!.hitTestChildren(result, position: transformed) ||
            // ignore: invalid_use_of_protected_member
            child!.hitTestSelf(transformed);
      },
    );
  }

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

  /// current journey
  var _journey = Journey.tighten(Offset.zero);

  /// for animation
  AnimationController? _controller;
  Animation<Offset>? _animation;

  /// cache of [Offset]s for calculation
  var _cache = OffsetCache();

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

  /// Track the last layout offset (parent-provided) and painted offset (actual)
  /// used for hit test transform computation.
  Offset? _lastLayoutOffset;
  Offset? _lastPaintedOffset;

  /// Current animated position in global coordinates (for backward compatibility)
  Offset _currentAnimatedOffset = Offset.zero;

  /// Implementation of [RenderAnimatedTo.currentAnimatedTransform]
  ///
  /// Computes the full transformation matrix from child coordinate space
  /// to boundary coordinate space, including any ancestor transforms
  /// (rotations, scales, etc.) and the animation offset.
  @override
  Matrix4? get currentAnimatedTransform {
    if (_boundary == null ||
        _lastPaintedOffset == null ||
        _lastLayoutOffset == null) {
      return null;
    }

    // getTransformTo captures the FULL transformation chain:
    // - All Transform.rotate matrices
    // - All Transform.scale matrices
    // - All layout offsets
    // This transforms from our local coords → boundary coords
    final treeTransform = getTransformTo(_boundary);

    // Compose with the animation delta.
    // getTransformTo already includes the layout offset. We only need to
    // add the delta between the painted offset and layout offset.
    final delta = _lastPaintedOffset! - _lastLayoutOffset!;
    // Post-multiply: T_full = T_tree × T_delta
    final result = treeTransform.clone();
    // ignore: deprecated_member_use
    result.translate(delta.dx, delta.dy);

    return result;
  }

  /// Implementation of [RenderAnimatedTo.currentAnimatedOffset]
  @override
  Offset? get currentAnimatedOffset => _currentAnimatedOffset;

  @override
  Offset get globalOffset => localToGlobal(
      Offset(
        _horizontalScrollOffset ?? 0,
        _verticalScrollOffset ?? 0,
      ),
      ancestor: _ancestor ?? _boundary);

  ScrollController? _verticalController;
  set verticalController(ScrollController? value) {
    // // Update the listener when the controller is changed
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
    // // Update the listener when the controller is changed
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
  /// note that [offset] also changes when scrolling on [SingleChildScrollView].
  @override
  void paint(PaintingContext context, Offset offset) {
    _lastLayoutOffset = offset;
    final boundaryOffset = localToGlobal(Offset.zero, ancestor: _boundary);

    final cacheMutation = OffsetCacheMutation(
      lastOffset: offset,
      lastGlobalOffset: globalOffset,
      lastAncestorGlobalOffset: _ancestor?.globalOffset ?? Offset.zero,
      lastBoundaryOffset: boundaryOffset,
    );

    final ancestorChanged = _lastAncestor != _ancestor;
    _lastAncestor = _ancestor;

    final prioriActions = switch ((_enabled, _journey.isPreparing)) {
      // if disabled, just keep the position for the next chance to animate.
      (false, _) => composeDisabled(
          _controller?.isAnimating == true,
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
      _applyMutation([cacheMutation, ...prioriActions].contextPovided(context));
      return;
    }

    // Animation is now active, regardless of animating right now or not.
    final animationActions = composeAnimation(
      animationValue: _animation?.value,
      offset: offset,
      globalOffset: globalOffset,
      boundaryOffset: boundaryOffset,
      ancestorChanged: ancestorChanged,
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
        case AnimationStart(:final journey):
          // Register with boundary when animation starts
          if (hitTestEnabled) _boundary?.registerAnimatingWidget(this);
          _controller = AnimationController(
            vsync: _vsync,
            duration: _duration,
          );

          _controller?.duration = _duration;
          _controller!.addListener(_attemptPaint);

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
          // Unregister from boundary when animation ends
          _boundary?.unregisterAnimatingWidget(this);
          _onEnd?.call(AnimationEndCause.completed);
          _controller?.removeListener(_attemptPaint);
          _controller?.dispose();
          _controller = null;
          _animation = null;
        case AnimationCancel():
          // Unregister from boundary when animation is cancelled
          _boundary?.unregisterAnimatingWidget(this);
          _onEnd?.call(AnimationEndCause.interrupted);
          _controller?.removeListener(_attemptPaint);
          _controller?.dispose();
          _controller = null;
          _animation = null;
        case PaintChild(:final offset, :final context):
          assert(context != null, 'context is required');
          // Track the paint offset for transform calculation
          _lastPaintedOffset = offset;
          // Update current animated position in global coordinates (for backward compatibility)
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
    if (_controller != null) {
      _applyMutation(
        [_controller!.isAnimating ? AnimationCancel() : AnimationEnd()],
      );
    }
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
