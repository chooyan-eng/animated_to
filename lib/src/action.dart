import 'package:animated_to/src/journey.dart';
import 'package:flutter/rendering.dart';

/// [MutationAction] is a value that represents a mutation to be applied
sealed class MutationAction {}

/// [MutationAction] to mutate the current [Journey] value.
final class JourneyMutation extends MutationAction {
  JourneyMutation(this.value);
  final Journey value;
}

/// [MutationAction] to start an animation with [journey] and [velocity] if provided.
final class AnimationStart extends MutationAction {
  /// from/to positions of the animation.
  final Journey journey;

  /// initial velocity of the animation, if any.
  final Offset? velocity;

  AnimationStart(this.journey, this.velocity);
}

/// [MutationAction] to indicate the end of animation.
final class AnimationEnd extends MutationAction {}

/// [MutationAction] to cancel the ongoing animation.
final class AnimationCancel extends MutationAction {}

/// [MutationAction] to paint the child at [offset].
/// Because paint operation requires [PaintingContext], which is not
/// available at the time of composing mutation actions, [context] is nullable at first,
/// and should be provided later by calling [provide].
final class PaintChild extends MutationAction {
  /// The offset to paint the child.
  final Offset offset;

  /// The [PaintingContext] to paint the child.
  final PaintingContext? context;

  /// Creates a [PaintChild] with the given [offset], but requires [PaintingContext] to be provided later.
  factory PaintChild.requireContext(Offset offset) =>
      PaintChild._(offset, null);

  /// Creates a new [PaintChild] with [context] and the same [offset].
  PaintChild provide(PaintingContext context) => PaintChild._(offset, context);

  PaintChild._(this.offset, this.context);
}

/// [MutationAction] to cache offsets for future reference.
class OffsetCacheMutation extends MutationAction {
  /// The offset at the start of the animation.
  /// This is not a starting position of the animation, but the destination position.
  final Offset? startOffset;

  /// The last offset provided via [paint] method.
  final Offset? lastOffset;

  /// The last global offset calculated in the last frame.
  /// "global" meeans relative to ancestor [RenderAnimatedTo] or [AnimatedToBoundary],
  /// or to the screen if no ancestor boundary is found.
  final Offset? lastGlobalOffset;

  /// The last offset relative to the nearest ancestor [AnimatedToBoundary].
  final Offset? lastBoundaryOffset;

  /// The last global offset of the nearest ancestor [RenderAnimatedTo].
  final Offset? lastAncestorGlobalOffset;

  OffsetCacheMutation({
    this.startOffset,
    this.lastOffset,
    this.lastGlobalOffset,
    this.lastBoundaryOffset,
    this.lastAncestorGlobalOffset,
  });
}
