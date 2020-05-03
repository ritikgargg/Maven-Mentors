import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _routeName) {
    return navigatorKey.currentState.pushReplacementNamed(_routeName);
  }

  Future<dynamic> navigateTo(String _routeName) {
    return navigatorKey.currentState.pushNamed(_routeName);
  }
  Future<dynamic> navigateToAndRemoveAll(String _routeName) {
    return navigatorKey.currentState.pushNamedAndRemoveUntil(_routeName, (_)=> false);
  }
   Future<dynamic> navigateToAndRemoveAllRoutes(MaterialPageRoute _routeName) {
    return navigatorKey.currentState.pushAndRemoveUntil(_routeName, (_)=> false);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState.push(_route);
  }
  Future<dynamic> navigateToReplacementRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState.pushReplacement(_route);
  }


  bool goBack() {
    return navigatorKey.currentState.pop();
  }
}
