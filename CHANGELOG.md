# Changelog

## 1.8.0

- Expose `GoProviderRoute.shellBuilder/shellPageBuilder`.
- Fix `GoProviderRoute.parentNavigatorKey` losing provider scope.
- Fix `Page` builders to correctly apply `Page.canPop/onPopInvoked`.
- Bump to sdk `3.0.0`.

## 1.7.0

- Added preload support to `ShellfulRoute`.
- Update `ShellRouteContext.navigatorBuilder` signature.
- Update `go_router` constraints to '>=14.5.0 <15.0.0'.

## 1.6.1

- Fixed `GoProviderRoute` not recreating it's providers when the same route is called again but with different path parameters.

## 1.6.0

- Added `ShellProviderRoute.redirect`.

## 1.5.0

- Bump `go_router` to '>=14.0.0 <15.0.0'.
- Added `ShellfulRoute` and `ShellfulProviderRoute` versions of `StatefulShellRoute.indexedStack`.

## 1.4.0

- Fixed `GoProviderRoute` not being tracked in ancestor observers.
- Added `GoPopButton` for leveraging `GoRouter`'s implicit pop.

## 1.3.0

- Added support to consuming declared providers directly in `ShellProviderRoute` builders in addition to it's routes.
- Bump `go_router` constraints to '>=10.2.0 <14.0.0' for `onExit` full compability.

## 1.2.0

- Added support to `GoProviderRoute` pageBuilder transitions.
- Updated README.md.

## 1.1.1

- Added example.
- Updated README.md.
- Bumped `flutter_lints` dev_dependency to 3.0.0.

## 1.1.0

- Simplified `ShellProviderRoute` to make it less sensitive to future changes in `go_router`.
- Removed `redirect` in `ShellProviderRoute`, as it will be rewritten in `go_router` future versions.

## 1.0.3

- Changed go_router constraints to '>=10.0.0 <14.0.0'.

## 1.0.2

- Added GitHub repository.
- Updated README.md and topics.

## 1.0.1

- Changed go_router constraints to '>=10.0.0 <13.0.0'.

## 1.0.0

- Initial release.
