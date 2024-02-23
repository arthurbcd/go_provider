# GoProvider

This package aim to provide a simple way to scope providers to a route in go_router. Making it possible to:

- Scope routes: access a provider in a route and it's sub-routes.
- Auto dispose: the provider is disposed when the route is popped.

This package is compatible with `go_router` v10.0.0 and above. This package less than 100 lines of code, you can copy and paste it in your project. Modify it to your needs.

## The Problem

```dart
routes: [
    GoRoute(
        path: '/login',
        builder: (context, state) => MyLoginPage(), // do NOT have access to UserState
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => UserState(),
        child: const MyPage(), // have access to UserState
      ),
      routes: [
        GoRoute(
          path: 'info',
          builder: (context, state) => const MySettingsPage(), // throws ProviderNotFoundException on UserState
        ),
      ],
    ),
]
```

## GoProvider Solution

```dart
routes: [
    GoRoute(
        path: '/login',
        builder: (context, state) => MyLoginPage(), // do NOT have access UserNotifier
    ),
    GoProviderRoute(
        path: '/home',
        providers: [
            ChangeNotifierProvider(create: (_) => UserState()), // or BlocProvider(...)
        ],
        builder: (context, state) => const MyPage(), // have access to UserNotifier
        routes: [
            GoRoute(
                path: '/settings',
                builder: (context, state) => const MySettingsPage(), // have access to UserNotifier too!
            ),
        ],
    ),
]
```

You can also use `ShellProviderRoute`:

```dart
routes: [
    ShellProviderRoute(
        builder: (context, state, child) => MyPage(child: child), // can access OtherState
        providers: [
            ChangeNotifierProvider(create: (context) => OtherState()),
        ],
        routes: [
            GoRoute(
                path: '/page1',
                builder: (context, state) => const MyPage1(), // can access OtherState
            ),
            GoRoute(
                path: '/page2',
                builder: (context, state) => const MyPage2(), // can access OtherState
            ),
        ],
    ),
]
```

## Nested

- You can actually use any Widget that extends `SingleChildWidget`. Which makes it compatible with `provider` and `flutter_bloc` packages right out of the box.
