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

/// A single reservation of a delayed animation.
///
/// Every position change detected while `delay` is non-zero produces one
/// reservation: "start moving toward the position of that change, once
/// [deadline] has passed". Reservations fire in order, so an earlier move
/// starts on time even if further moves are reserved afterwards; each later
/// reservation then redirects the running animation when its own deadline
/// comes.
class DelayReservation {
  const DelayReservation({
    required this.deadline,
    required this.destinationShift,
  });

  /// When this reservation fires, in the delay ticker's elapsed time.
  final Duration deadline;

  /// The destination of this reservation, expressed as
  /// `offset - destinationShift` where `offset` is the current paint offset.
  ///
  /// The destination is stored as a shift from the current layout position
  /// (which may keep moving) so that scrolling — which moves `offset` but not
  /// the global offset — is followed naturally, while later layout moves
  /// don't drag old destinations along.
  final Offset destinationShift;

  DelayReservation shiftedBy(Offset delta) => DelayReservation(
        deadline: deadline,
        destinationShift: destinationShift + delta,
      );
}

/// State of the delayed animations waiting to start.
///
/// All shifts are in the effective global coordinates used by
/// [hasChangedPosition] and are accumulated every frame the position changes,
/// so that subtracting them from the current paint offset yields positions
/// that follow scrolling but ignore layout moves.
class PendingDelay {
  const PendingDelay({
    required this.reservations,
    required this.heldShift,
    required this.animationShift,
  });

  static const empty = PendingDelay(
    reservations: [],
    heldShift: Offset.zero,
    animationShift: Offset.zero,
  );

  /// Reservations in deadline order.
  final List<DelayReservation> reservations;

  /// The position where the child currently rests, expressed as
  /// `offset - heldShift`: before any reservation has fired, where the child
  /// was when the first change was reserved; after a fire, that fire's
  /// destination (where the child settles if its animation completes before
  /// the next deadline).
  final Offset heldShift;

  /// Accumulated layout movement since the currently running animation
  /// started. While an animation toward a reserved (possibly stale)
  /// destination is running, the painted position is
  /// `animationValue + (offset - startOffset) - animationShift`,
  /// so that only scrolling follows.
  final Offset animationShift;

  /// Applies a newly detected layout movement of [delta] to every tracked
  /// shift.
  PendingDelay shiftedBy(Offset delta) => PendingDelay(
        reservations: [for (final r in reservations) r.shiftedBy(delta)],
        heldShift: heldShift + delta,
        animationShift: animationShift + delta,
      );

  /// Adds a new reservation at the end (deadlines are monotonically
  /// increasing because every reservation uses the same `delay`).
  PendingDelay reserved(DelayReservation reservation) => PendingDelay(
        reservations: [...reservations, reservation],
        heldShift: heldShift,
        animationShift: animationShift,
      );
}

extension ProvideContextExt on List<MutationAction> {
  List<MutationAction> contextPovided(PaintingContext context) => map(
        (mutation) =>
            mutation is PaintChild ? mutation.provide(context) : mutation,
      ).toList();
}
