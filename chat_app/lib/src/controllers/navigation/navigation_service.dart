import 'package:chat_app/src/screens/authentication/login_screen.dart';
import 'package:chat_app/src/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../settings/settings_controller.dart';

part 'navigation_animations.dart';
// part 'navigation_routing.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // ignore: non_constant_identifier_names
  NavigationService({required this.settingsController});
  SettingsController settingsController;

  List<String> routeStack = [LoginScreen.route];
  String get currentRoute {
    String result = '';
    if (routeStack.isNotEmpty) {
      result = routeStack.last;
    }
    return result;
  }

  addToRouteStackRecord(String routeName) {
    routeStack.add(routeName);
    logCurrentRoute();
  }

  replaceLastRouteStackRecord(String routeName) {
    if (routeStack.isEmpty) {
      routeStack.add(routeName);
    } else {
      routeStack[routeStack.length - 1] = routeName;
    }
    logCurrentRoute();
  }

  popLastRouteStackRecord() {
    if (routeStack.isNotEmpty) {
      routeStack.removeLast();
    } else {
      print(
          'The routeStack ended up empty, check if there was some error, falling back to last known screen');
      routeStack.add(currentRoute);
    }
    logCurrentRoute();
  }

  Future<Object> showDialog(
      {required Widget child,
      BuildContext? context,
      String identifier = 'dialog',
      bool barrierDismissible = false}) async {
    addToRouteStackRecord(identifier);
    Object result = await material.showDialog(
        context:
            context ?? navigatorKey.currentContext as material.BuildContext,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          return child;
        });
    popLastRouteStackRecord();
    return result;
  }

  Future<Object> showModalBottomSheet({
    required Widget child,
    BuildContext? context,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    AnimationController? transitionAnimationController,
    String identifier = 'modalBottomSheet',
  }) async {
    addToRouteStackRecord(identifier);
    Object result = await material.showModalBottomSheet(
        routeSettings: RouteSettings(name: identifier),
        context: context ?? navigatorKey.currentContext as BuildContext,
        builder: (BuildContext dialogContext) {
          return child;
        },
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        barrierColor: barrierColor,
        isScrollControlled: isScrollControlled,
        useRootNavigator: useRootNavigator,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        transitionAnimationController: transitionAnimationController);
    popLastRouteStackRecord();
    return result;
  }

  logCurrentRoute() {
    log('Currently on $currentRoute, stack: $routeStack',
        origin: 'NavigationService');
  }

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) async {
    log('Pushing [$routeName]', origin: 'NavigationService');
    addToRouteStackRecord(routeName);
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic>? pushReplacementNamed(String routeName,
      {Object? arguments, Object? result}) {
    log('Pushing replacement [$routeName]', origin: 'NavigationService');
    replaceLastRouteStackRecord(routeName);
    return navigatorKey.currentState
        ?.pushReplacementNamed(routeName, arguments: arguments, result: result);
  }

  Future<Object?> push(Route<Object> route) {
    log('Pushing route [${route.settings.name}]', origin: 'NavigationService');

    return navigatorKey.currentState!.push(route);
  }

  Future<Object?> pushReplacement(Route<Object> route, {Object? result}) {
    log('Pushing replacement route [${route.settings.name}]',
        origin: 'NavigationService');
    return navigatorKey.currentState!.pushReplacement(route, result: result);
  }

  bool get isFirst => !navigatorKey.currentState!.canPop();

  pop<T extends Object>([T? result]) {
    popLastRouteStackRecord();
    navigatorKey.currentState!.pop(result);
  }

  popUntilFirst() {
    routeStack = [routeStack.first];
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    logCurrentRoute();
  }

  SettingsController get sc => settingsController;

  // static PageRoute Function(RouteSettings settings) get generateRoute =>
  //     getRoute;

  log(String message, {String? origin}) {
    developer.log(message,
        name: 'NavigationService${origin != null ? '/' + origin : ''}');
  }

  material.PageRoute getRoute(RouteSettings settings) {
    // NavigationService nav = locator<NavigationService>();
    if (FirebaseAuth.instance.currentUser != null) {
      return FadeRoute(
          page: HomeScreen(settingsController: settingsController),
          settings: settings);
    } else {
      return FadeRoute(page: const LoginScreen(), settings: settings);
    }
    // print(settings.name);
    // switch (settings.name) {
    //   // case Wrapper.route:
    //   //   return FadeRoute(page: Wrapper(), settings: settings);
    //   case LoginScreen.route:
    //     return FadeRoute(page: const LoginScreen(), settings: settings);
    //   case HomeScreen.route:
    //     return FadeRoute(
    //         page: HomeScreen(settingsController: settingsController),
    //         settings: settings);
    //   default:
    //     return FadeRoute(page: const LoginScreen(), settings: settings);
    // }
  }
}
