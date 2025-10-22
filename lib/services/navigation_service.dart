import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Reference to the GoRouter instance
  static late GoRouter router;
  
  // Initialize with the app's GoRouter
  static void init(GoRouter goRouter) {
    router = goRouter;
  }
  
  // Navigate to a named route without context
  static void navigateTo(String route) {
    router.go(route);
  }
  
  // Navigate to a route while preserving the back stack
  static void navigatePush(String route) {
    router.push(route);
  }
  
  // Navigate and replace current route
  static void navigateReplace(String route) {
    router.replace(route);
  }
  
  // Go back
  static void goBack() {
    router.pop();
  }
}