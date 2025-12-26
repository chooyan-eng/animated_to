import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/let.dart';
import 'package:flutter/widgets.dart';

List<MutationAction> composeDisabled(
  bool isAnimating,
  Offset offset,
) =>
    [
      isAnimating ? AnimationCancel() : AnimationEnd(),
      PaintChild.requireContext(offset),
    ];

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

List<MutationAction> composeAnimation({
  required Offset? animationValue,
  required bool isAnimating,
  Offset? velocity,
  required Offset offset,
  required Offset globalOffset,
  required Offset boundaryOffset,
  required bool ancestorChanged,
  required Offset? ancestorGlobalOffset,
  required OffsetCache cache,
}) =>
    ((
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
            ...switch ((
              isAnimating: isAnimating,
              hasPositionChanged: hasChangedPosition,
            )) {
              (isAnimating: false, hasPositionChanged: false) => [
                  PaintChild.requireContext(offset),
                ],
              (isAnimating: false, hasPositionChanged: true) =>
                // cache scroll offset and position considering scroll gap
                // regardless of whether animating now or not.
                Journey(
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

bool hasChangedPosition({
  required Offset lastGlobalOffset,
  required Offset currentGlobalOffset,
  Offset? lastAncestorGlobalOffset,
  Offset? currentAncestorGlobalOffset,
}) {
  final ancestorOffsetGap = (currentAncestorGlobalOffset ?? Offset.zero) -
      (lastAncestorGlobalOffset ?? Offset.zero);
  final selfOffsetGap = currentGlobalOffset - lastGlobalOffset;
  final gap = (selfOffsetGap - ancestorOffsetGap).abs;
  return gap.dx.toInt() != 0 || gap.dy.toInt() != 0;
}

extension on Offset {
  Offset get abs => Offset(dx.abs(), dy.abs());
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
