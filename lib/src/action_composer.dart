import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/let.dart';
import 'package:animated_to/animated_to.dart';
import 'package:flutter/widgets.dart';

/// This file contains functions to compose mutation actions.
/// [MutationAction] is a value that represents a mutation to be applied.
/// The functions of this file only returns a list of [MutationAction]s
/// without any side effects, and also they are pure, meaning that
/// they don't deped on any external state, and always return the same output
/// for the same input.
///
/// [composeDisabled] composes mutation actions when [AnimatedTo] is disabled,
/// which means [enabled] is [false].
///
/// In the funtions below, some parameters with the same names have the same meanings:
/// - [offset] is the position passed via [paint] method of [RenderAnimatedTo] from its parent.
/// - [globalOffset] is [Offset] relative to ancestor [RenderAnimatedTo] or [AnimatedToBoundary],
///   or to the screen if no ancestor boundary is found.
/// - [boundaryOffset] is [Offset] relative to the nearest ancestor [AnimatedToBoundary].
/// - [ancestorGlobalOffset] is [globalOffset] of the nearest ancestor [RenderAnimatedTo].
///
/// And also, they receive [OffsetCache] which contains these offsets above in the last frame
/// so that the functions can determine whether the position has changed or not.

/// In this situation, no animation should be performed, this means:
/// - If animation is in progress, where [isAnimating] is [true],
///   it should be cancelled and painted at the destination position([offset]) immediately.
/// - If a delayed animation is waiting to start, where [isWaiting] is [true],
///   it should be discarded.
/// - If no animation is not happening, just paint at [offset].
List<MutationAction> composeDisabled(
  bool isAnimating,
  Offset offset, {
  bool isWaiting = false,
}) =>
    [
      if (isAnimating) AnimationCancel(),
      if (isWaiting) DelayedAnimationCancel(),
      PaintChild.requireContext(offset),
    ];

/// Composes mutation actions for the first frame when the widget is built.
/// Depending on whether [appearingFrom] or [slidingFrom] is provided,
/// it composes different actions to start the animation from the specified position.
/// If neither is provided, it just paints the child at [offset] without animation.
/// If both are provided, it throws [UnsupportedError].
///
/// [appearingFrom] means the child of [AnimatedTo] should appear from the given
/// absolute position in the global coordinate system.
///
/// [slidingFrom] means the child of [AnimatedTo] should appear from the given
/// position relative to its intrinsic position.
List<MutationAction> composeFirstFrame(
  Offset? appearingFrom,
  Offset? slidingFrom,
  Offset offset,
) =>
    switch ((appearingFrom, slidingFrom)) {
      (final Offset from, null) =>
        Journey(from: from, to: offset).let((journey) => [
              ..._composeStartAnimation(
                false,
                journey,
              ),
              PaintChild.requireContext(journey.from),
            ])!,
      (null, final Offset from) =>
        Journey(from: offset + from, to: offset).let((journey) => [
              ..._composeStartAnimation(
                false,
                journey,
              ),
              PaintChild.requireContext(journey.from),
            ])!,
      (null, null) => [
          // if neither of [_appearingFrom] or [_slidingFrom] is given,
          // just render [child] with the default operation.
          JourneyMutation(Journey.tighten(offset)),
          PaintChild.requireContext(offset),
        ],
      _ => throw UnsupportedError(
          'appearingFrom and slidingFrom can\'t be provided at the same time.',
        ),
    };

/// Composes mutation actions for animation frames.
///
/// Depending on the situations and given parameters, it composes different actions:
/// - If no animation is happening([isAnimating] is false) and the position hasn't changed,
///   it just paints the child at [offset].
/// - If no animation is happening and the position has changed,
///   it starts a new animation from the previous position to [offset].
/// - If animation is already happening([isAnimating] is true) and the position hasn't changed,
///   this means the animation can continue, so it paints the child at the current animated position.
/// - If animation is already happening and the position has changed,
///   it starts a new animation from the current animated position to [offset].
///
/// However, wether "position has changed" or not is difficult to determine,
/// because the position, or [globalOffset] may change due to ancestor [AnimatedTo]s' movements.
/// Therefore, to determine whether the position has changed or not,
/// it compares the change of [globalOffset] with the change of
/// [ancestorGlobalOffset] of the nearest ancestor [AnimatedTo].
///
/// Also, [offset] to be painted during animation is adjusted with respect to
/// the difference between [offset] and [startOffset] cached in [OffsetCache],
/// because [offset] may change during animation due to scrolling, though [animationValue] doesn't.
List<MutationAction> composeAnimation({
  /// The current animated position in local coordinates.
  /// Basically this value should be applied as [Offset] to paint the child during animation.
  /// However, because the actual offset may change due to scrolling,
  /// the gap between [offset] and cached [startOffset] is added to this value in reality.
  required Offset? animationValue,

  /// The velocity of the animation, if any.
  Offset? velocity,

  /// The position of [AnimatedTo], where its child should originally be painted.
  required Offset offset,

  /// The global position of [AnimatedTo]
  required Offset globalOffset,

  /// The global position relative to the nearest ancestor [AnimatedToBoundary].
  required Offset boundaryOffset,

  /// Whether the nearest ancestor [AnimatedTo] has changed since last frame.
  required bool ancestorChanged,

  /// The global position of the nearest ancestor [AnimatedTo].
  required Offset? ancestorGlobalOffset,

  /// Cached offsets from the last frame.
  required OffsetCache cache,

  /// How long to wait after a position change before starting the animation.
  /// [Duration.zero] means the animation starts immediately, which is
  /// exactly the same behavior as before this parameter was introduced.
  Duration delay = Duration.zero,

  /// The waiting state of a delayed animation scheduled in a previous frame,
  /// or null if no delayed animation is waiting.
  PendingDelay? pendingDelay,

  /// Whether the delay of [pendingDelay] has expired, meaning the delayed
  /// animation should start in this frame. Never true while [pendingDelay] is null.
  bool delayExpired = false,
}) =>
    ((
      // If ancestor has changed, which means this [AnimatedTo] moves to another branch of the tree,
      // we should consider boundary offset instead of global offset, because we have to compare
      // the position relative to the nearest ancestor [AnimatedToBoundary].
      // On the other hand, if ancestor [AnimatedTo] hasn't changed, we have to consider global offset,
      // which is relative to that ancestor [AnimatedTo], because even if the ancestor [AnimatedTo] moves
      // at the same frame with this [AniamatedTo], [globalOffset] is agnostic to that movement.
      // This means, [AnimatedTo] does NOT support the situation where "move to another branch of the tree" and
      // "the ancestor [AnimatedTo] moves at the same frame" happen at the same time.
      current: ancestorChanged ? boundaryOffset : globalOffset,
      cached: ancestorChanged
          ? cache.lastBoundaryOffset ?? boundaryOffset
          : cache.lastGlobalOffset ?? globalOffset
    )).let((effectiveGlobalOffsets) => hasChangedPosition(
          lastGlobalOffset: cache.lastGlobalOffset ?? globalOffset,
          currentGlobalOffset: globalOffset,
          lastAncestorGlobalOffset:
              cache.lastAncestorGlobalOffset ?? ancestorGlobalOffset,
          currentAncestorGlobalOffset: ancestorGlobalOffset,
        ).let(
          (hasChangedPosition) => [
            ...composeDelayed(
                  isAnimating: animationValue != null,
                  hasChangedPosition: hasChangedPosition,
                  layoutDelta: effectiveGlobalOffsets.current -
                      effectiveGlobalOffsets.cached,
                  animationValue: animationValue,
                  velocity: velocity,
                  offset: offset,
                  startOffset: cache.startOffset,
                  delay: delay,
                  pendingDelay: pendingDelay,
                  delayExpired: delayExpired,
                ) ??
                switch ((
                  isAnimating: animationValue != null,
                  hasPositionChanged: hasChangedPosition,
                )) {
              (isAnimating: false, hasPositionChanged: false) => [
                  PaintChild.requireContext(offset),
                ],
              (isAnimating: false, hasPositionChanged: true) => Journey(
                      // detect how much the position has changed since last frame first,
                      // and then create a journey to the new [offset] from the gap
                      // relative to [offset].
                      from: offset -
                          (effectiveGlobalOffsets.current -
                              effectiveGlobalOffsets.cached),
                      to: offset)
                  .let((journey) => [
                        ..._composeStartAnimation(
                          false,
                          journey,
                        ),
                        PaintChild.requireContext(journey.from),
                      ])!,
              (isAnimating: true, hasPositionChanged: false) => [
                  PaintChild.requireContext(
                      animationValue! + (offset - cache.startOffset!)),
                ],
              (isAnimating: true, hasPositionChanged: true) => Journey(
                  // This situation is complex. First, we have to determine
                  // how much gap we have from the current animated position to the target position,
                  // then, we have to specify how much the child should move during the next animation
                  // based on the global/boundary offset changes,
                  // finally we can make [Journey] from the gap-applied position and target [offset].
                  from: (cache.lastOffset! - animationValue!)
                      .let((gap) => effectiveGlobalOffsets.cached - gap)
                      .let((currentBoundaryOffset) =>
                          effectiveGlobalOffsets.current -
                          currentBoundaryOffset)
                      .let((gap) => offset - gap)!,
                  to: offset,
                ).let((journey) => [
                      // if [position] is updated during animation,
                      // start another animation from current position
                      ..._composeStartAnimation(
                        true,
                        journey,
                        velocity: velocity,
                      ),
                      PaintChild.requireContext(journey.from),
                    ])!
            },
          ],
        )!)!;

/// Composes mutation actions for the "delayed animation" feature of [composeAnimation].
/// Returns null when the delay feature doesn't apply to this frame,
/// meaning [composeAnimation] should fall back to the immediate behavior,
/// which is exactly the behavior before the delay feature was introduced.
///
/// [layoutDelta] is how much this [AnimatedTo] itself has moved since the last frame
/// in the effective global coordinates (which is zero when the position hasn't changed).
/// While waiting, the "held" position is derived as [offset] minus the accumulated
/// [PendingDelay.layoutShift], so that scrolling — which moves [offset] but not
/// the global offset — is followed naturally, while layout changes — which move
/// the global offset — are compensated and don't move the held child.
/// This also covers the case where scrolling and a layout change happen in the same frame.
List<MutationAction>? composeDelayed({
  required bool isAnimating,
  required bool hasChangedPosition,
  required Offset layoutDelta,
  required Offset? animationValue,
  required Offset? velocity,
  required Offset offset,
  required Offset? startOffset,
  required Duration delay,
  required PendingDelay? pendingDelay,
  required bool delayExpired,
}) {
  // While a previous animation is running, the held position is its current
  // painted position (with the usual scroll adjustment); otherwise it's the
  // layout position. Either way the accumulated layout shift is subtracted
  // so that only scrolling follows.
  Offset holdPosition(Offset shift) => isAnimating
      ? animationValue! + (offset - startOffset!) - shift
      : offset - shift;

  if (pendingDelay != null) {
    final shift = pendingDelay.layoutShift +
        (hasChangedPosition ? layoutDelta : Offset.zero);

    if (!delayExpired) {
      // Still waiting: keep painting at the held position. If the position
      // changed again during the wait, only the accumulated shift is updated;
      // the deadline is NOT reset, and the destination is always the latest
      // [offset] resolved when the delay expires.
      return [
        if (hasChangedPosition)
          PendingDelayMutation(PendingDelay(layoutShift: shift)),
        PaintChild.requireContext(holdPosition(shift)),
      ];
    }

    // The delay has expired: start the animation from the held position
    // (or from the current animated position if the previous animation is
    // still running, keeping its velocity) to the latest destination.
    return Journey(from: holdPosition(shift), to: offset).let((journey) => [
          DelayedAnimationCancel(),
          ..._composeStartAnimation(
            isAnimating,
            journey,
            velocity: isAnimating ? velocity : null,
          ),
          PaintChild.requireContext(journey.from),
        ])!;
  }

  if (hasChangedPosition && delay > Duration.zero) {
    // The position has changed and a delay is requested: don't start the
    // animation yet. A running animation keeps going to its original
    // destination; a static child keeps being painted at its old position.
    return [
      DelayedAnimationSchedule(PendingDelay(layoutShift: layoutDelta)),
      PaintChild.requireContext(holdPosition(layoutDelta)),
    ];
  }

  return null;
}

/// Determines whether the position has changed compared to the last frame.
/// This can't be easily determined by simply comparing [lastGlobalOffset] and [currentGlobalOffset],
/// because the position may change due to ancestor [AnimatedTo]s' movements.
/// Therefore, this function compares the change of [globalOffset] with the change of
/// [ancestorGlobalOffset] of the nearest ancestor [AnimatedTo].
@visibleForTesting
bool hasChangedPosition({
  required Offset lastGlobalOffset,
  required Offset currentGlobalOffset,
  Offset? lastAncestorGlobalOffset,
  Offset? currentAncestorGlobalOffset,
}) {
  final ancestorOffsetGap = (currentAncestorGlobalOffset ?? Offset.zero) -
      (lastAncestorGlobalOffset ?? Offset.zero);
  final selfOffsetGap = currentGlobalOffset - lastGlobalOffset;
  final gap = (selfOffsetGap - ancestorOffsetGap);
  return gap.dx.toInt() != 0 || gap.dy.toInt() != 0;
}

List<MutationAction> _composeStartAnimation(
  bool isAnimating,
  Journey journey, {
  Offset? velocity,
}) =>
    [
      if (isAnimating) AnimationCancel(),
      JourneyMutation(journey),
      OffsetCacheMutation(startOffset: journey.to),
      AnimationStart(journey, velocity),
    ];
