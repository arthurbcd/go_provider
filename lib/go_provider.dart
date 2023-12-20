library go_provider;

import 'package:flutter/widgets.dart';
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
        );
}

/// A class that mimics [ShellRoute], but with additional support for scoped providers.
class ShellProviderRoute extends ShellRoute {
  /// Creates a [ShellProviderRoute] with the given [providers] and [routes].
  ///
  /// See [ShellRoute] for more information.
  ShellProviderRoute({
    required this.providers,
    required List<RouteBase> routes,
    this.redirect,
    super.navigatorKey,
    super.observers,
    super.parentNavigatorKey,
    super.restorationScopeId,
    super.builder,
    super.pageBuilder,
  }) : super(routes: redirect == null ? routes : _routes(routes, redirect));

  /// A list of providers to be nested in the route.
  final List<SingleChildWidget> providers;

  /// A [redirect] callback to be applied to all nested [routes].
  ///
  /// See [GoRouterRedirect] for more information.
  final GoRouterRedirect? redirect;

  /// A static method that adds [redirect] to nested routes.
  static List<RouteBase> _routes(
    List<RouteBase> routes,
    GoRouterRedirect redirect,
  ) {
    return routes.map((route) {
      if (route is! GoRoute) return route;
      return GoRoute(
        path: route.path,
        name: route.name,
        builder: route.builder,
        pageBuilder: route.pageBuilder,
        parentNavigatorKey: route.parentNavigatorKey,
        redirect: (context, state) {
          final shellResult = redirect(context, state);

          if (shellResult is String?) {
            return shellResult ?? route.redirect?.call(context, state);
          }
          return shellResult.then((result) {
            return result ?? route.redirect?.call(context, state);
          });
        },
        onExit: route.onExit,
        routes: route.routes,
      );
    }).toList();
  }

  Widget _nest(ShellRouteContext shellRouteContext) {
    final navigator =
        shellRouteContext.navigatorBuilder(observers, restorationScopeId);
    return Nested(children: providers, child: navigator);
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
