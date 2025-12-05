import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A container widget that enables hit testing for animating [AnimatedTo] descendants.
///
/// When [AnimatedTo] widgets are animating, they visually move to new positions but
/// their hit test areas remain at their layout positions. [AnimatedToContainer] solves
/// this by intercepting hit tests and checking animating descendants at their animated
/// positions first.
///
/// [AnimatedToContainer] should typically be placed near the root of the widget tree
/// so that all the [AnimatedTo] widgets moving around the entire screen are covered.
///
/// Example:
/// ```dart
/// AnimatedToContainer(
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
class AnimatedToContainer extends SingleChildRenderObjectWidget {
  const AnimatedToContainer({
    super.key,
    required super.child,
  });

  /// Retrieves the nearest [RenderAnimatedToContainer] from the given [context].
  ///
  /// Returns null if no [AnimatedToContainer] ancestor is found.
  static RenderAnimatedToContainer? of(BuildContext context) {
    return context.findAncestorRenderObjectOfType<RenderAnimatedToContainer>();
  }

  /// Creates a [RenderAnimatedToContainer] which performs custom hit testing.
  @override
  RenderAnimatedToContainer createRenderObject(BuildContext context) {
    return RenderAnimatedToContainer();
  }
}

/// A [RenderProxyBox] that performs custom hit testing for animating descendants.
///
/// This render object maintains a list of currently animating [RenderAnimatedTo]
/// objects and performs hit testing on them at their animated positions before
/// falling back to normal hit testing.
class RenderAnimatedToContainer extends RenderProxyBox {
  /// List of currently animating render objects.
  final List<RenderAnimatedTo> _animatingWidgets = [];

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
    for (final animatingWidget in _animatingWidgets) {
      final animatedOffset = animatingWidget.currentAnimatedOffset;
      final isHit = result.addWithPaintOffset(
        offset: animatedOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - animatedOffset);
          return animatingWidget.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }

    // No animating widget was hit, fall back to normal hit testing
    return super.hitTest(result, position: position);
  }
}

/// Base interface for render objects that can be registered with [RenderAnimatedToContainer].
///
/// This is implemented by both spring and curve versions of [RenderAnimatedTo].
abstract class RenderAnimatedTo extends RenderProxyBox {
  /// The current animated position in global coordinates.
  Offset get currentAnimatedOffset;
}
