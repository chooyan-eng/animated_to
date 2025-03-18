import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/journey.dart';
import 'package:animated_to/src/let.dart';
import 'package:animated_to/src/widget.dart';
import 'package:flutter/widgets.dart';

List<MutationAction> composeDisabled(
  AnimationController? controller,
  Offset offset,
  PaintingContext context,
) =>
    [
      if (controller != null)
        controller.isAnimating ? AnimationCancel() : AnimationEnd(),
      JourneyMutation(Journey.tighten(offset)),
      PaintChild(offset, context),
    ];

List<MutationAction> composeFirstFrame(
  Offset? appearingFrom,
  Offset? slidingFrom,
  Offset offset,
  double scrollOffset,
  PaintingContext context,
) =>
    switch ((appearingFrom, slidingFrom)) {
      (final Offset from, null) =>
        Journey(from: from, to: offset).let((journey) => [
              JourneyMutation(journey),
              AnimationStart(journey),
              PositionCacheMutation(
                scrollOffsetWhenAnimationStarted: scrollOffset,
              ),
              PaintChild(journey.from, context)
            ])!,
      (null, final Offset from) => Journey(
          from: offset + from,
          to: offset,
        ).let((journey) => [
              JourneyMutation(journey),
              AnimationStart(journey),
              PositionCacheMutation(
                scrollOffsetWhenAnimationStarted: scrollOffset,
              ),
              PaintChild(journey.from, context)
            ])!,
      (null, null) => [
          // if neither of [_appearingFrom] or [_slidingFrom] is given,
          // just render [child] with the default operation.

          JourneyMutation(Journey.tighten(offset)),
          PaintChild(offset, context),
        ],
      _ => <MutationAction>[],
    };

List<MutationAction> composeAnimation(
  AnimationController? controller,
  Animation<Offset>? animation,
  PositionCache cache,
  Offset offset,
  Journey journey,
  double? scrollOffset,
  PaintingContext context,
) =>
    [
      PositionCacheMutation(lastOffset: offset),
      ...switch ((
        isScrolling: cache.scrollOffsetCache != scrollOffset, // isScrolling
        isAnimating: controller?.isAnimating == true, // isAnimating
      )) {
        (isScrolling: true, isAnimating: true) => [
            // cache scroll offset and position considering scroll gap
            // regardless of whether animating now or not.
            PositionCacheMutation(scrollOffset: scrollOffset),
            JourneyMutation(Journey.tighten(offset)),
            PaintChild(
              animation!.value +
                  Offset(
                    0,
                    cache.scrollOffsetWhenAnimationStarted! - scrollOffset!,
                  ),
              context,
            ),
          ],
        (isScrolling: true, isAnimating: false) => (
            scrollGap: (cache.scrollOffsetCache ?? 0.0) - scrollOffset!,
            positionGap: offset - (cache.lastOffset ?? offset)
          ).let((it) => [
                // cache scroll offset and position considering scroll gap
                // regardless of whether animating now or not.
                PositionCacheMutation(scrollOffset: scrollOffset),
                JourneyMutation(Journey.tighten(offset)),
                ...(it.scrollGap - it.positionGap.distance).abs() > 40
                    ? [
                        if (controller != null)
                          controller.isAnimating
                              ? AnimationCancel()
                              : AnimationEnd(),
                        AnimationStart(Journey(from: journey.to, to: offset)),
                        PositionCacheMutation(
                          scrollOffsetWhenAnimationStarted: scrollOffset,
                        ),
                        PaintChild(journey.from, context),
                      ]
                    : [PaintChild(offset, context)],
              ])!,
        (isScrolling: false, :final isAnimating) => [
            if (journey.to != offset)
              ...Journey(
                from: isAnimating
                    ? animation!.value -
                        Offset(
                          0,
                          (scrollOffset ?? 0) -
                              (cache.scrollOffsetWhenAnimationStarted ?? 0),
                        )
                    : journey.to,
                to: offset,
              ).let((journey) => [
                    // if [position] is updated during animation,
                    // start another animation from current position
                    JourneyMutation(journey),
                    if (controller != null)
                      controller.isAnimating
                          ? AnimationCancel()
                          : AnimationEnd(),
                    AnimationStart(journey),
                    PositionCacheMutation(
                      scrollOffsetWhenAnimationStarted: scrollOffset ?? 0.0,
                    ),
                    PaintChild(journey.from, context),
                  ])!
            else ...[
              PaintChild(
                switch ((animation?.value, scrollOffset)) {
                  (final Offset value, final double offset) => value +
                      Offset(
                        0,
                        cache.scrollOffsetWhenAnimationStarted! - offset,
                      ),
                  (null, _) => offset,
                  (final Offset value, null) => value
                },
                context,
              ),
            ],
          ],
      },
    ];
