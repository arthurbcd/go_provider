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
                  final page = pageBuilder(context, state);

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
                      child: child,
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
                      child: child,
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
                      child: child,
                    );
                  }

                  final route = page.createRoute(context);

                  if (route is ModalRoute) {
                    return CustomTransitionPage(
                      key: page.key,
                      name: page.name,
                      arguments: page.arguments,
                      restorationId: page.restorationId,
                      opaque: route.opaque,
                      fullscreenDialog:
                          route is PageRoute && route.fullscreenDialog,
                      barrierDismissible: route.barrierDismissible,
                      barrierColor: route.barrierColor,
                      barrierLabel: route.barrierLabel,
                      maintainState: route.maintainState,
                      transitionsBuilder: route.buildTransitions,
                      transitionDuration: route.transitionDuration,
                      reverseTransitionDuration:
                          route.reverseTransitionDuration,
                      child: child,
                    );
                  }

                  return NoTransitionPage(
                    key: page.key,
                    arguments: page.arguments,
                    name: page.name,
                    restorationId: page.restorationId,
                    child: child,
                  );
                }
              : null,
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

  Widget _nest(ShellRouteContext shellRouteContext) {
    return Nested(
      children: providers,
      child: shellRouteContext.navigatorBuilder(observers, restorationScopeId),
    );
  }

  @override
  Widget? buildWidget(context, state, shellRouteContext) {
    if (builder == null && pageBuilder == null) return _nest(shellRouteContext);
    return builder?.call(context, state, _nest(shellRouteContext));
  }

  @override
  Page<dynamic>? buildPage(context, state, shellRouteContext) {
    return pageBuilder?.call(context, state, _nest(shellRouteContext));
  }
}
