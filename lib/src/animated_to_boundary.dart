import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A boundary widget that enables hit testing for animating [AnimatedTo] descendants
/// and establishes a stable coordinate origin for position calculations.
///
/// ## Purpose 1: Hit Testing During Animation
///
/// When [AnimatedTo] widgets are animating, they visually move to new positions but
/// their hit test areas remain at their layout positions. [AnimatedToBoundary] solves
/// this by intercepting hit tests and checking animating descendants at their animated
/// positions first.
///
/// ## Purpose 2: Coordinate System Origin
///
/// [AnimatedToBoundary] establishes a boundary that serves as the origin for coordinate
/// calculations. This prevents [AnimatedTo] from being affected by ancestor animations
/// such as whole-screen transitions (e.g., Navigator.push/pop).
///
/// When you wrap a page widget (typically [Scaffold]) with [AnimatedToBoundary], the
/// coordinate system becomes isolated from navigation transitions. Without this isolation,
/// [AnimatedTo] would incorrectly interpret the page slide animation as a position change
/// and create unexpected animations.
///
/// ## Usage
///
/// [AnimatedToBoundary] should typically be placed:
/// - Near the root of the widget tree for global hit testing coverage
/// - Around individual page widgets to isolate navigation transition effects
///
/// Example for global hit testing:
/// ```dart
/// AnimatedToBoundary(
///   child: MaterialApp(
///     home: Column(
///       children: [
///         AnimatedTo.spring(
///           globalKey: GlobalObjectKey(item1),
///           child: MyWidget(),
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
///
/// Example for isolating navigation transitions:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return AnimatedToBoundary(
///     child: Scaffold(
///       body: AnimatedTo.spring(
///         globalKey: _key,
///         slidingFrom: Offset(100, 0),
///         child: YourWidget(),
///       ),
///     ),
///   );
/// }
/// ```
///
/// Note that [AnimatedToBoundary] can be nested, so you don't need to remove
/// other [AnimatedToBoundary] widgets when adding a new one.
class AnimatedToBoundary extends SingleChildRenderObjectWidget {
  const AnimatedToBoundary({
    super.key,
    required super.child,
    this.hitTestOverflow = false,
  });

  /// Retrieves the nearest [RenderAnimatedToBoundary] from the given [context].
  ///
  /// Returns null if no [AnimatedToBoundary] ancestor is found.
  static RenderAnimatedToBoundary? of(BuildContext context) {
    return context.findAncestorRenderObjectOfType<RenderAnimatedToBoundary>();
  }

  /// When true, allows hit testing outside this widget's layout bounds.
  ///
  /// Defaults to `false`.
  final bool hitTestOverflow;

  /// Creates a [RenderAnimatedToBoundary] which performs custom hit testing.
  @override
  RenderAnimatedToBoundary createRenderObject(BuildContext context) {
    return RenderAnimatedToBoundary(hitTestOverflow: hitTestOverflow);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAnimatedToBoundary renderObject) {
    renderObject.hitTestOverflow = hitTestOverflow;
  }
}

/// A [RenderProxyBox] that performs custom hit testing for animating descendants.
///
/// This render object maintains a list of currently animating [RenderAnimatedTo]
/// objects and performs hit testing on them at their animated positions before
/// falling back to normal hit testing.
class RenderAnimatedToBoundary extends RenderProxyBox {
  RenderAnimatedToBoundary({bool hitTestOverflow = false})
      : _hitTestOverflow = hitTestOverflow;

  /// List of currently animating render objects.
  final List<RenderAnimatedTo> _animatingWidgets = [];

  bool _hitTestOverflow = false;
  set hitTestOverflow(bool value) {
    _hitTestOverflow = value;
  }

  /// Registers an animating render object.
  ///
  /// Called by [RenderAnimatedTo] when it starts animating.
  void registerAnimatingWidget(RenderAnimatedTo renderObject) {
    if (!_animatingWidgets.contains(renderObject)) {
      _animatingWidgets.add(renderObject);
    }
  }

  /// Unregisters an animating render object.
  ///
  /// Called by [RenderAnimatedTo] when animation ends or is cancelled.
  void unregisterAnimatingWidget(RenderAnimatedTo renderObject) {
    _animatingWidgets.remove(renderObject);
  }

  /// Performs hit testing to currently animating widgets first.
  /// If none are hit, falls back to normal hit testing.
  ///
  /// Note that this hit testing is z-order agnostic, which means it may
  /// report a hit on a widget that is visually behind another widget.
  ///
  /// TODO(chooyan-eng): consider z-order, but how?
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    _animatingWidgets.removeWhere(
      (renderObject) =>
          !renderObject.attached ||
          !renderObject.hitTestEnabled ||
          renderObject.currentAnimatedTransform == null,
    );

    bool hitTestWidget(RenderAnimatedTo animatingWidget) {
      final transform = animatingWidget.currentAnimatedTransform!;
      // Use addWithPaintTransform instead of addWithPaintOffset to properly
      // handle rotations, scales, and other transforms between the boundary
      // and the animating widget.
      final isHit = result.addWithPaintTransform(
        transform: transform,
        position: position,
        hitTest: (BoxHitTestResult result, Offset? transformed) {
          if (transformed == null) {
            // Transform is degenerate (not invertible, e.g., scale=0)
            return false;
          }
          // Hit test the AnimatedTo's children directly
          return animatingWidget.hitTestChildren(result, position: transformed);
        },
      );
      if (isHit) {
        _addAncestorHitTestEntries(result, animatingWidget, position);
      }
      return isHit;
    }

    for (final animatingWidget in _animatingWidgets) {
      if (hitTestWidget(animatingWidget)) {
        return true;
      }
    }

    // No registered widget was hit, fall back to normal hit testing.
    if (_hitTestOverflow) {
      if (hitTestChildren(result, position: position) ||
          hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    }
    return super.hitTest(result, position: position);
  }

  void _addAncestorHitTestEntries(
    BoxHitTestResult result,
    RenderObject leaf,
    Offset position,
  ) {
    final globalPosition = localToGlobal(position);
    RenderObject? ancestor = leaf.parent;
    while (ancestor != null && ancestor != this) {
      if (ancestor is RenderBox) {
        final localPosition = ancestor.globalToLocal(globalPosition);
        result.add(BoxHitTestEntry(ancestor, localPosition));
      }
      ancestor = ancestor.parent;
    }
    result.add(BoxHitTestEntry(this, position));
  }
}

/// Base interface for render objects that can be registered with [RenderAnimatedToBoundary].
///
/// This is implemented by both spring and curve versions of [RenderAnimatedTo].
abstract class RenderAnimatedTo extends RenderProxyBox {
  /// The full transformation matrix from this widget's child coordinate space
  /// to the boundary's coordinate space.
  ///
  /// This matrix includes:
  /// - The animation offset (translation applied during painting)
  /// - All transforms between this widget and the boundary (rotations, scales, etc.)
  ///
  /// Returns null if not currently animating or if no boundary is set.
  Matrix4? get currentAnimatedTransform;

  /// The current animated position offset.
  ///
  /// Note: This is just the translation component and may be inaccurate
  /// when transforms (rotation/scale) exist between boundary and this widget.
  /// Use [currentAnimatedTransform] for accurate hit testing with transforms.
  Offset? get currentAnimatedOffset;

  /// The offset of this render object in global coordinates.
  Offset get globalOffset;

  /// Controls whether hit testing is performed at the animated position during animation.
  ///
  /// When `true`, this widget will respond to hit tests at its current animated position
  /// while animating. When `false`, hit tests will only occur at the widget's layout position.
  ///
  /// Note: This flag only affects behavior during animation. When the widget is not animating,
  /// hit testing always occurs at the widget's normal layout position regardless of this setting.
  bool get hitTestEnabled;
}
