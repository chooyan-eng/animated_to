## [0.7.0] - 2025.12.11
- AnimatedTo now can be nested!
- Fixed a bug of unexpected behavior when scrolling.

## [0.6.2] - 2025.12.6
- Fixed tiny lint issues.

## [0.6.1] - 2025.12.5
- Fixed tiny lint issues.

## [0.6.0] - 2025.12.5
- Add `AnimatedToContainer` to detect gesture to descendant `AnimatedTo`s during their animation. 

## [0.5.0] - 2025.12.3
- `animated_to` now depends on `motor` instead of `springster`. Thank you [@timcreatedit](https://github.com/timcreatedit)
- listeners attached to `horizontalController` and `verticalController` are now properly disposed when `AnimatedTo` is disposed. Thank you [@nappannda](https://github.com/nappannda)

## [0.4.0] - 2025.7.9
- Support animation on horizontal `SingleChildScrollView`. 
- `controller` is renamed to `verticalController`.

## [0.3.3+1] - 2025.7.8
- Update document and example about `ListView`.

## [0.3.3] - 2025.7.7
- enhanced the logic of how to detect position updates when scrolling
- fixed error when markNeedsPaint is called during previous paint phases

## [0.3.2] - 2025.3.21
- add `sizeWidget` argument that enables us to collaborate with size animation

## [0.3.1] - 2025.3.20
- add `velocityBuilder` argument to `AnimatedTo.spring()`

## [0.3.0] - 2025.3.19
- `AnimatedTo()` is now separated into `AnimatedTo.curve()` and `AnimatedTo.spring()`
- some refactoring with experimental idea to make the logic testable
- added dependency to [springster](https://pub.dev/packages/springster) package.

## [0.2.0] - 2024.12.27
- remove unnecessary `vsync` argument
- rename `key` to `globalKey` and make it `required`
- some refactoring and write documentation

## [0.1.1] - 2024.12.20
- fix behavior on `SingleChildScrollView`

## [0.1.0] - 2024.12.17
- write some basic documentation

## [0.0.4] - 2024.12.17
- add `onEnd` callback to handle animation end
- some refactoring

## [0.0.3] - 2024.12.16
- add `enabled` property to control animation

## [0.0.2] - 2024.12.15
- update README.md

## [0.0.1] - 2024.12.15

### first release of `AnimatedTo`. 
- available features:
  - basic behavior of `AnimatedTo`
  - configure duration and curve of animation
  - configure initial position to start animation at the first frame

