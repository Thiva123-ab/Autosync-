import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../constants/app_roles.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../../features/auth/presentation/customer_login_page.dart';
import '../../features/auth/presentation/staff_login_page.dart';
import '../../features/customer/presentation/home_page.dart';
import '../../features/dashboard/admin/presentation/admin_dashboard.dart';
import '../../features/dashboard/mechanic/presentation/mechanic_dashboard.dart';
import '../../features/dashboard/advisor/presentation/advisor_dashboard.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRoleState = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/staff-login';
      
      if (userRoleState.isLoading) {
        return null; // Wait for role to load before redirecting
      }

      if (!isLoggedIn) {
        if (!isLoggingIn) return '/login';
        return null;
      }

      if (isLoggingIn) {
        // User is logged in but trying to access login page
        final role = userRoleState.role;
        switch (role) {
          case AppRoles.admin:
            return '/admin';
          case AppRoles.mechanic:
            return '/mechanic';
          case AppRoles.serviceAdvisor:
            return '/advisor';
          case AppRoles.customer:
          default:
            return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const CustomerHomePage(title: 'Customer Home Page'),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const CustomerLoginPage(title: 'Customer Login'),
      ),
      GoRoute(
        path: '/staff-login',
        name: RouteNames.staffLogin,
        builder: (context, state) => const StaffLoginPage(title: 'Staff Login'),
      ),
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboard(title: 'Admin Dashboard'),
      ),
      GoRoute(
        path: '/mechanic',
        name: RouteNames.mechanicDashboard,
        builder: (context, state) => const MechanicDashboard(title: 'Mechanic Dashboard'),
      ),
      GoRoute(
        path: '/advisor',
        name: RouteNames.advisorDashboard,
        builder: (context, state) => const AdvisorDashboard(title: 'Advisor Dashboard'),
      ),
    ],
  );
});
