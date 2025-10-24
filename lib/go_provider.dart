library go_provider;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nested/nested.dart';

/// A class that mimics [GoRoute], but with additional support for scoped providers.
class GoProviderRoute extends ShellProviderRoute {
  /// Creates a [GoProviderRoute] with the given [path] and [providers].
  ///
  /// See [GoRoute] for more information.
  GoProviderRoute({
    required String path,
    required super.providers,
    String? name,
    GoRouterWidgetBuilder? builder,
    GoRouterPageBuilder? pageBuilder,
    GoRouterRedirect? redirect,
    ExitCallback? onExit,
    List<RouteBase> routes = const [],
    super.parentNavigatorKey,
    ShellRouteBuilder? shellBuilder,
    ShellRoutePageBuilder? shellPageBuilder,
  }) : super(
          routes: [
            GoRoute(
              path: path,
              name: name,
              builder: builder,
              pageBuilder: pageBuilder,
              redirect: redirect,
              onExit: onExit,
              routes: routes,
            ),
          ],
          builder: shellBuilder,
          pageBuilder: switch ((pageBuilder, shellPageBuilder)) {
            (null, null) => null,
            (_, var builder?) => builder,
            (var builder?, _) => (context, state, child) {
                return builder(context, state).nest((_) => child);
              },
          },
          observers: [_InheritObservers()],
        );
}

/// A class that mimics [ShellRoute], but with additional support for scoped providers.
class ShellProviderRoute extends ShellRoute {
  /// Creates a [ShellProviderRoute] with the given [providers] and [routes].
  ///
  /// See [ShellRoute] for more information.
  ShellProviderRoute({
    required this.providers,
    required super.routes,
    super.redirect,
    super.navigatorKey,
    super.observers,
    super.parentNavigatorKey,
    super.restorationScopeId,
    super.builder,
    super.pageBuilder,
  });

  /// A list of providers to be nested in the route.
  final List<SingleChildWidget> Function(
    BuildContext context,
    GoRouterState state,
  ) providers;

  Widget _nest(BuildContext context, GoRouterState state, Widget child) {
    return Nested(
      key: () {
        if (this is! GoProviderRoute) return null;

        final route = routes.first as GoRoute;
        // we recreate when any parameter this route depends on changes.
        // ignore: invalid_use_of_internal_member
        final values = route.pathParameters.map((k) => state.pathParameters[k]);
        return Key(values.toString());
      }(),
      children: providers(context, state),
      child: child,
    );
  }

  @override
  Widget? buildWidget(context, state, shellRouteContext) {
    if (pageBuilder != null) return null;

    final child = Builder(builder: (context) {
      return super.buildWidget(context, state, shellRouteContext) ??
          shellRouteContext.build(observers, restorationScopeId);
    });

    return _nest(context, state, child);
  }

  @override
  Page? buildPage(context, state, shellRouteContext) {
    final page = super.buildPage(context, state, shellRouteContext);

    return page?.nest((child) => _nest(context, state, child));
  }
}

extension on ShellRouteContext {
  Widget build(List<NavigatorObserver>? observers, String? restorationScopeId) {
    return navigatorBuilder(
      navigatorKey,
      match,
      routeMatchList,
      observers,
      restorationScopeId,
    );
  }
}

class ShellfulProviderRoute extends ShellfulRoute {
  ShellfulProviderRoute({
    required super.routes,
    required List<SingleChildWidget> providers,
    StatefulShellRouteBuilder? builder,
    super.redirect,
    super.parentNavigatorKey,
    super.restorationScopeId,
    super.preload,
  }) : super(
          builder: (context, state, child) {
            return Nested(
              children: providers,
              child: builder?.call(context, state, child) ?? child,
            );
          },
        );
}

class ShellfulRoute extends StatefulShellRoute {
  ShellfulRoute({
    required List<RouteBase> routes,
    super.redirect,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.restorationScopeId,
    bool preload = false,
  }) : super.indexedStack(
          branches: [
            for (final route in routes)
              StatefulShellBranch(
                routes: [route],
                preload: preload,
              )
          ],
        );
}

class _InheritObservers extends NavigatorObserver {
  List<NavigatorObserver> get observers {
    final state = navigator?.context.findAncestorStateOfType<NavigatorState>();
    return state?.widget.observers ?? [];
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    for (final observer in observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final observer in observers) {
      observer.didStopUserGesture();
    }
  }
}

extension on Page {
  Page nest(Widget Function(Widget child) nester) {
    return switch (this) {
      CupertinoPage page => CupertinoPage(
          key: page.key,
          name: page.name,
          arguments: page.arguments,
          allowSnapshotting: page.allowSnapshotting,
          fullscreenDialog: page.fullscreenDialog,
          maintainState: page.maintainState,
          restorationId: page.restorationId,
          title: page.title,
          canPop: page.canPop,
          onPopInvoked: page.onPopInvoked,
          child: nester(page.child),
        ),
      MaterialPage page => MaterialPage(
          key: page.key,
          name: page.name,
          arguments: page.arguments,
          allowSnapshotting: page.allowSnapshotting,
          fullscreenDialog: page.fullscreenDialog,
          maintainState: page.maintainState,
          restorationId: page.restorationId,
          canPop: page.canPop,
          onPopInvoked: page.onPopInvoked,
          child: nester(page.child),
        ),
      CustomTransitionPage page => CustomTransitionPage(
          key: page.key,
          name: page.name,
          arguments: page.arguments,
          opaque: page.opaque,
          restorationId: page.restorationId,
          maintainState: page.maintainState,
          fullscreenDialog: page.fullscreenDialog,
          barrierDismissible: page.barrierDismissible,
          barrierColor: page.barrierColor,
          barrierLabel: page.barrierLabel,
          transitionsBuilder: page.transitionsBuilder,
          transitionDuration: page.transitionDuration,
          reverseTransitionDuration: page.reverseTransitionDuration,
          child: nester(page.child),
        ),
      _ => () {
          try {
            dynamic page = this;
            return page.copyWith(
              child: nester(page.child),
            );
          } catch (_) {}
          throw GoError(
            'Could not build page from route: $this \n'
            'Please make sure the page extends a MaterialPage, CupertinoPage, or CustomTransitionPage. \n'
            'Or implement a copyWith({Widget? child}) method in your custom Page class.',
          );
        }(),
    };
  }
}

/// A button that returns either a [CloseButton] or a [BackButton] based on the
/// current route's fullscreenDialog property.
class GoPopButton extends StatelessWidget {
  const GoPopButton({super.key, this.color, this.style, this.onPressed});
  final Color? color;
  final ButtonStyle? style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final useCloseButton = route is PageRoute && route.fullscreenDialog;
    final actionButton = useCloseButton ? CloseButton.new : BackButton.new;

    return actionButton(
      color: color,
      style: style,
      onPressed: onPressed ?? context.pop,
    );
  }
}
