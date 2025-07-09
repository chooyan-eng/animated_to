import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/helper.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/let.dart';
import 'package:flutter/widgets.dart';
import 'package:springster/springster.dart';

List<MutationAction> composeDisabled(
  bool? isAnimating,
  Offset offset,
) =>
    [
      if (isAnimating != null) isAnimating ? AnimationCancel() : AnimationEnd(),
      JourneyMutation(Journey.tighten(offset)),
      PaintChild.requireContext(offset),
    ];

List<MutationAction> composeFirstFrame(
  Offset? appearingFrom,
  Offset? slidingFrom,
  Offset offset,
  Offset scrollOffset,
) =>
    switch ((appearingFrom, slidingFrom)) {
      (final Offset from, null) =>
        Journey(from: from, to: offset).let((journey) => [
              JourneyMutation(journey),
              AnimationStart(journey, null),
              OffsetCacheMutation(scrollOriginal: scrollOffset),
              PaintChild.requireContext(journey.from),
            ])!,
      (null, final Offset from) =>
        Journey(from: offset + from, to: offset).let((journey) => [
              JourneyMutation(journey),
              AnimationStart(journey, null),
              OffsetCacheMutation(scrollOriginal: scrollOffset),
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

List<MutationAction> composeAnimation(
  AnimationController? controller,
  Offset? animationValue,
  Offset offset,
  Offset scrollOffset,
  Journey journey,
  OffsetCache cache,
  bool dirtyLayout,
) =>
    [
      OffsetCacheMutation(last: offset, scroll: scrollOffset),
      ...switch ((
        isScrolling: cache.scrollLast != scrollOffset,
        isAnimating: controller?.isAnimating == true,
      )) {
        (isScrolling: true, isAnimating: true) => [
            // cache scroll offset and position considering scroll gap
            // regardless of whether animating now or not.
            JourneyMutation(Journey.tighten(offset)),
            PaintChild.requireContext(
              animationValue! + cache.scrollOriginal! - scrollOffset,
            ),
          ],
        (isScrolling: true, isAnimating: false) => (
            scrollGap: (cache.scrollLast ?? Offset.zero) - scrollOffset,
            positionGap: offset - (cache.last ?? offset)
          ).let((it) => [
                // cache scroll offset and position considering scroll gap
                // regardless of whether animating now or not.
                ...dirtyLayout
                    ? Journey(from: journey.to, to: offset).let((journey) => [
                          ..._composeStartAnimation(
                            controller?.isAnimating == true,
                            journey,
                            scrollOffset,
                          ),
                          PaintChild.requireContext(journey.from),
                        ])!
                    : [
                        JourneyMutation(Journey.tighten(offset)),
                        PaintChild.requireContext(offset),
                      ],
              ])!,
        (isScrolling: false, :final isAnimating) => journey.to != offset
            ? Journey(
                from: isAnimating
                    ? animationValue! -
                        (scrollOffset - (cache.scrollOriginal ?? Offset.zero))
                    : journey.to,
                to: offset,
              ).let((journey) => [
                  // if [position] is updated during animation,
                  // start another animation from current position
                  ..._composeStartAnimation(
                    controller?.isAnimating == true,
                    journey,
                    scrollOffset,
                  ),
                  PaintChild.requireContext(journey.from),
                ])!
            : [
                PaintChild.requireContext(
                  switch ((animationValue, scrollOffset)) {
                    (final Offset value, final Offset offset) =>
                      value + (cache.scrollOriginal! - offset),
                    _ => offset,
                  },
                ),
              ],
      },
    ];

List<MutationAction> composeSpringAnimation(
  SpringSimulationController2D controller,
  Offset offset,
  Offset scrollOffset,
  Journey journey,
  OffsetCache cache,
  bool dirtyLayout,
) =>
    [
      OffsetCacheMutation(last: offset, scroll: scrollOffset),
      ...switch ((
        isScrolling: cache.scrollLast != scrollOffset,
        isAnimating: controller.isAnimating,
      )) {
        (isScrolling: true, isAnimating: true) => [
            // cache scroll offset and position considering scroll gap
            // regardless of whether animating now or not.
            JourneyMutation(Journey.tighten(offset)),
            PaintChild.requireContext(
              Offset(controller.value.x, controller.value.y) +
                  cache.scrollOriginal! -
                  scrollOffset,
            ),
          ],
        (isScrolling: true, isAnimating: false) => (
            scrollGap: (cache.scrollLast ?? Offset.zero) - scrollOffset,
            positionGap: offset - (cache.last ?? offset)
          ).let((it) => [
                // cache scroll offset and position considering scroll gap
                // regardless of whether animating now or not.
                ...dirtyLayout
                    ? Journey(from: journey.to, to: offset).let((journey) => [
                          ..._composeStartAnimation(
                            controller.isAnimating,
                            journey,
                            scrollOffset,
                          ),
                          PaintChild.requireContext(journey.from),
                        ])!
                    : [
                        JourneyMutation(Journey.tighten(offset)),
                        PaintChild.requireContext(offset),
                      ],
              ])!,
        (isScrolling: false, :final isAnimating) => journey.to != offset
            ? Journey(
                from: isAnimating
                    ? Offset(controller.value.x, controller.value.y) -
                        (scrollOffset - (cache.scrollOriginal ?? Offset.zero))
                    : journey.to,
                to: offset,
              ).let((journey) => [
                  // if [position] is updated during animation,
                  // start another animation from current position
                  ..._composeStartAnimation(
                    controller.isAnimating,
                    journey,
                    scrollOffset,
                  ),
                  PaintChild.requireContext(journey.from),
                ])!
            : [
                PaintChild.requireContext(
                  switch ((controller.isAnimating, scrollOffset)) {
                    (true, final Offset offset) =>
                      Offset(controller.value.x, controller.value.y) +
                          cache.scrollOriginal! -
                          offset,
                    (true, Offset.zero) =>
                      Offset(controller.value.x, controller.value.y),
                    (false, _) => offset,
                  },
                ),
              ],
      },
    ];

List<MutationAction> _composeStartAnimation(
  bool isAnimating,
  Journey journey,
  Offset? scrollOffset, {
  (double, double)? velocity,
}) =>
    [
      if (isAnimating) AnimationCancel(),
      JourneyMutation(journey),
      AnimationStart(journey, velocity),
      OffsetCacheMutation(scrollOriginal: scrollOffset),
    ];
