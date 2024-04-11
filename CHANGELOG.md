# Changelog

## 1.4.0

- Fixed `GoProviderRoute` not being tracked in ancestor observers.
- Added `GoPopButton` for leveraging `GoRouter`'s implicit pop.

## 1.3.0

- Added support to consuming declared providers directly in `ShellProviderRoute` builders in addition to it's routes.
- Changed go_router constraints to '>=10.2.0 <14.0.0' for `onExit` full compability.

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
