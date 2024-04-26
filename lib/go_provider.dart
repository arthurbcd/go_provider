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
    GlobalKey<NavigatorState>? parentNavigatorKey,
    GoRouterRedirect? redirect,
    ExitCallback? onExit,
    List<RouteBase> routes = const [],
  }) : super(
          routes: [
            GoRoute(
              path: path,
              name: name,
              builder: builder,
              pageBuilder: pageBuilder,
              parentNavigatorKey: parentNavigatorKey,
              redirect: redirect,
              onExit: onExit,
              routes: routes,
            ),
          ],
          pageBuilder: pageBuilder != null
              ? (context, state, child) {
                  return pageBuilder(context, state).nest((_) => child);
                }
              : null,
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
    super.navigatorKey,
    super.observers,
    super.parentNavigatorKey,
    super.restorationScopeId,
    super.builder,
    super.pageBuilder,
  });

  /// A list of providers to be nested in the route.
  final List<SingleChildWidget> providers;

  Widget _nest(Widget child) {
    return Nested(
      children: providers,
      child: child,
    );
  }

  @override
  Widget? buildWidget(context, state, shellRouteContext) {
    if (pageBuilder != null) return null;

    final widget = super.buildWidget(context, state, shellRouteContext);
    if (widget != null) return _nest(widget);

    return _nest(
      shellRouteContext.navigatorBuilder(observers, restorationScopeId),
    );
  }

  @override
  Page<dynamic>? buildPage(context, state, shellRouteContext) {
    return super.buildPage(context, state, shellRouteContext)?.nest(_nest);
  }
}

class ShellfulProviderRoute extends ShellfulRoute {
  ShellfulProviderRoute({
    required super.routes,
    required List<SingleChildWidget> providers,
    StatefulShellRouteBuilder? builder,
    super.parentNavigatorKey,
    super.restorationScopeId,
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
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super.indexedStack(
          branches:
              routes.map((e) => StatefulShellBranch(routes: [e])).toList(),
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
    final page = this;

    if (page is CupertinoPage) {
      return CupertinoPage(
        key: page.key,
        name: page.name,
        arguments: page.arguments,
        allowSnapshotting: page.allowSnapshotting,
        fullscreenDialog: page.fullscreenDialog,
        maintainState: page.maintainState,
        restorationId: page.restorationId,
        title: page.title,
        child: nester(page.child),
      );
    }

    if (page is MaterialPage) {
      return MaterialPage(
        key: page.key,
        name: page.name,
        arguments: page.arguments,
        allowSnapshotting: page.allowSnapshotting,
        fullscreenDialog: page.fullscreenDialog,
        maintainState: page.maintainState,
        restorationId: page.restorationId,
        child: nester(page.child),
      );
    }

    if (page is CustomTransitionPage) {
      return CustomTransitionPage(
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
      );
    }

    throw GoError('Could not build page from route: $page'
        ''
        'Please make sure the page extends a MaterialPage, CupertinoPage, or CustomTransitionPage.');
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
