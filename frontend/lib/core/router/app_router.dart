import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/activity_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_home_page.dart';
import '../../features/dashboard/presentation/pages/main_shell_page.dart';
import '../../features/dashboard/presentation/pages/services_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/users/presentation/pages/user_detail_page.dart';
import '../../features/users/presentation/pages/user_form_page.dart';
import '../../features/users/presentation/pages/user_list_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Stateful Shell with Persistent Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardHomePage(),
              ),
            ],
          ),

          // Branch 1: User Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/users',
                builder: (context, state) => const UserListPage(),
              ),
            ],
          ),

          // Branch 2: Activity / Audit Log
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ActivityPage(),
              ),
            ],
          ),

          // Branch 3: Services
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (context, state) => const ServicesPage(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Standalone User CRUD screens
      GoRoute(
        path: '/users/add',
        builder: (context, state) => const UserFormPage(),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user != null) {
            return UserDetailPage(user: user);
          }
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return UserDetailPage(
            user: UserModel(
              id: id,
              name: 'Resident #$id',
              email: 'resident$id@nobroker.in',
            ),
          );
        },
      ),
      GoRoute(
        path: '/users/:id/edit',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          return UserFormPage(user: user);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
