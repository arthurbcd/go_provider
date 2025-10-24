# GoProvider

GoProvider aims to simplify provider scoping within go_router routes, offering:

- 🎯 Scoped Simplicity: Route-specific state access for cleaner code.
- 🏗️ Modular Design: No more 1.000 providers on the top of your app.
- ✨ Auto-Lifecycle: Providers inits on go and auto-disposes on route pop.
- 🚀 Streamlined State Management: Effortless integration with `provider` and `flutter_bloc`.
- 🚌 Bus-proof: An easy-to-maintain, single-file library you can copy-paste, just in case.

## The Problem

```dart
routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => LoginPage(), // ❌ can't access UserState
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => ChangeNotifierProvider( // or BlocProvider
      create: (_) => UserState(),
      child: const HomePage(), // ✅ can access UserState
    ),
    routes: [
      GoRoute(
        path: 'details',
        builder: (context, state) => const DetailsPage(), // ❌ throws ProviderNotFoundException
      ),
    ],
  ),
]
```

## GoProvider Solution

```dart
routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => LoginPage(), // ❌ can't access UserState
  ),
  GoProviderRoute(
    path: '/home',
    providers: (context, state) => [ // GoRouterState
      ChangeNotifierProvider(create: (_) => UserState()), // or BlocProvider
    ],
    builder: (context, state) => const HomePage(), // ✅ can access UserState
    routes: [
      GoRoute(
        path: 'details',
        builder: (context, state) => const DetailsPage(), // ✅ can access UserState too!
      ),
    ],
  ),
]
```

### You can also use `ShellProviderRoute`

```dart
routes: [
  ShellProviderRoute(
    providers: (context, state) => [
      ChangeNotifierProvider(create: (_) => FooState()), // or BlocProvider
    ],
    builder: (context, state, child) => ShellPage(child: child), // ✅ can access FooState
    routes: [
      GoRoute(
        path: '/a',
        builder: (context, state) => const PageA(), // ✅ can access FooState
      ),
      GoRoute(
        path: '/b',
        builder: (context, state) => const PageB(), // ✅ can access FooState
      ),
    ],
  ),
]
```

## Issues

### Navigator.pop

Since `GoProviderRoute` has its own `Navigator`, the canPop method will always return false. This means that the implicit back/close button wont show up. This a known issue when using `ShellRoute` routes:
<https://github.com/flutter/flutter/issues/144687>

For leveraging `GoRouter`'s implicit pop issue, you can use `GoPopButton`:

```dart
GoPopButton(), // CloseButton/BackButton that pops the current route (like AppBar's leading)
```

> Also prefer using `context.pop` instead of `Navigator.pop` inside `GoProviderRoute` routes.

### Custom `Page`

By default `pageBuilder` is only compatible with `MaterialPage`, `CupertinoPage` and `CustomTransitionPage`. Any custom `Page` that doesn't implement or extend those, will throw an exception when trying to nest providers.

For a `CustomPage`, you can implement `CustomPage.copyWith({Widget? child})` so go_provider can use it's child to nest providers.

## Contribution

Contributions are welcome! Feel free to submit pull requests or open issues on our GitHub repository. Don't forget to star/like the project if you like it.
