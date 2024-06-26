import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thefluttercorner/LoginScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:thefluttercorner/widgets/navigation/scaffold_with_navigation.dart';

import 'features/dashboard/dashbord_page.dart';
import 'features/users/users_page.dart';

part 'router.g.dart';

const routerInitialLocation = '/';

final router = GoRouter(
  routes: $appRoutes,
  debugLogDiagnostics: kDebugMode,
  initialLocation: routerInitialLocation,
);

@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch(
      routes: [
        TypedGoRoute<DashboardRoute>(
          path: routerInitialLocation,
        ),
      ],
    ),
    TypedStatefulShellBranch(
      routes: [
        TypedGoRoute<UsersPageRoute>(
          path: '/users',
          routes: [
            TypedGoRoute<UserPageRoute>(
              path: ':userId',
            ),
          ],
        ),
        TypedGoRoute<LoginPageRoute>(
          path: routerInitialLocation,
        ),
      ],

    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
      BuildContext context,
      GoRouterState state,
      StatefulNavigationShell navigationShell,
      ) {
    return SelectionArea(
      child: ScaffoldWithNavigation(
        navigationShell: navigationShell,
      ),
    );
  }
}

class DashboardRoute extends GoRouteData {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashBoardPage();
  }
}

class UsersPageRoute extends GoRouteData {
  const UsersPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UsersPage();
  }
}

class LoginPageRoute extends GoRouteData {
  const LoginPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

class UserPageRoute extends GoRouteData {
  const UserPageRoute({required this.userId});

  final String userId;

}
