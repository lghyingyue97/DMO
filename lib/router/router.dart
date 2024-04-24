import 'package:flutter/material.dart';

///路由路径
class RouteName {
  RouteName._();
}

class GoRouter {
  static late GlobalKey<NavigatorState> mNavigatorKey = GlobalKey();

  GoRouter._();

  static Map<String, RouterBuilder> routeMap = {};

  static void pop() {
    mNavigatorKey.currentContext?.pop();
  }

  static Route<T?> _materialPageRoute<T>(RouteSettings settings, Widget page,
      {bool fullscreenDialog = false}) {
    return MaterialPageRoute<T>(
        settings: settings,
        builder: (ctx) => page,
        fullscreenDialog: fullscreenDialog);
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return _Route(routeMap).get(settings);
  }
}

extension GoRouterHelper on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> push<T extends Object?>(Route<T> route) {
    return Navigator.of(this).push<T>(route);
  }

  ///删掉其它页面
  Future<T?> go<T extends Object?>(String routeName) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil<T>(routeName, (route) => false);
  }

  void pop<T extends Object?>([T? result]) {
    return Navigator.of(this).pop<T>(result);
  }

  void popUntil(RoutePredicate predicate) {
    return Navigator.of(this).popUntil(predicate);
  }
}

typedef Route RouterBuilder(RouteSettings settings);

class _Route {
  _Route(this.definitions);

  Route<dynamic>? get(final RouteSettings settings) {
    final matches =
        this.definitions.keys.where((route) => route == settings.name);
    final route = matches.length > 0 ? matches.first : null;

    return null != route ? definitions[route]!.call(settings) : null;
  }

  final Map<String, RouterBuilder> definitions;
}

class MyNavigatorObserver extends NavigatorObserver {
  static final navStack = <RouteStackItem>[];

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      navStack.removeLast();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    navStack.add(RouteStackItem.fromRoute(route));
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      navStack.removeLast();
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      navStack.removeLast();
    }
    if (newRoute != null) {
      navStack.add(RouteStackItem.fromRoute(newRoute));
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
  }
}

class RouteStackItem {
  final String? name;
  final Object? args;

  const RouteStackItem({
    required this.name,
    required this.args,
  });

  factory RouteStackItem.fromRoute(Route route) =>
      RouteStackItem(name: route.settings.name, args: route.settings.arguments);
}
