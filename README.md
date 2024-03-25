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
    providers: [
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
    providers: [
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

## Nested

- You can utilize any widget that extends `SingleChildWidget`, ensuring out-of-the-box compatibility with both `provider` and `flutter_bloc` packages.
