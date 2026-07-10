import 'package:animated_to/src/action.dart';
import 'package:flutter/rendering.dart';

/// cached values for calculation
class OffsetCache {
  OffsetCache({
    this.startOffset,
    this.lastOffset,
    this.lastGlobalOffset,
    this.lastBoundaryOffset,
    this.lastAncestorGlobalOffset,
  });

  final Offset? startOffset;
  final Offset? lastOffset;
  final Offset? lastGlobalOffset;
  final Offset? lastBoundaryOffset;
  final Offset? lastAncestorGlobalOffset;

  OffsetCache copyWith({
    Offset? startOffset,
    Offset? lastOffset,
    Offset? lastGlobalOffset,
    Offset? lastBoundaryOffset,
    Offset? lastAncestorGlobalOffset,
  }) =>
      OffsetCache(
        startOffset: startOffset ?? this.startOffset,
        lastOffset: lastOffset ?? this.lastOffset,
        lastGlobalOffset: lastGlobalOffset ?? this.lastGlobalOffset,
        lastBoundaryOffset: lastBoundaryOffset ?? this.lastBoundaryOffset,
        lastAncestorGlobalOffset:
            lastAncestorGlobalOffset ?? this.lastAncestorGlobalOffset,
      );
}

/// State of a delayed animation that has been scheduled but not started yet.
///
/// While [AnimatedTo] is waiting for the delay to expire, the child keeps
/// being painted at the position where it was when the position change was
/// detected. That "held" position is derived every frame as
/// `offset - layoutShift`, so that scrolling (which moves [offset] but not
/// the global offset) is followed naturally, while layout changes
/// (which move the global offset) are compensated and don't move the child.
class PendingDelay {
  const PendingDelay({required this.layoutShift});

  /// Accumulated movement of this [AnimatedTo] itself, in the effective
  /// global coordinates used by [hasChangedPosition], since the delay was
  /// scheduled. Updated every frame the position changes during the wait.
  final Offset layoutShift;
}

extension ProvideContextExt on List<MutationAction> {
  List<MutationAction> contextPovided(PaintingContext context) => map(
        (mutation) =>
            mutation is PaintChild ? mutation.provide(context) : mutation,
      ).toList();
}
