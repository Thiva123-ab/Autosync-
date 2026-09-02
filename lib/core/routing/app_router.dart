import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../constants/app_roles.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../../features/auth/presentation/customer_login_page.dart';
import '../../features/auth/presentation/staff_login_page.dart';
import '../../features/customer/presentation/home_page.dart';
import '../../features/customer/presentation/booking_page.dart';
import '../../features/chatbot/presentation/chatbot_page.dart';
import '../../features/dashboard/admin/presentation/admin_dashboard.dart';
import '../../features/dashboard/mechanic/presentation/mechanic_dashboard.dart';
import '../../features/dashboard/advisor/presentation/advisor_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(userRoleProvider);
      final isLoggedIn = !authState.isLoading && authState.role != null;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/staff-login';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoginRoute) return '/login';
      
      if (isLoggedIn) {
        // If they are on a login route, redirect to their home dashboard
        if (isLoginRoute) {
          switch (authState.role) {
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
        
        // Route Guards: Prevent access to other roles' dashboards
        final loc = state.matchedLocation;
        if (loc.startsWith('/admin') && authState.role != AppRoles.admin) return '/';
        if (loc.startsWith('/mechanic') && authState.role != AppRoles.mechanic) return '/';
        if (loc.startsWith('/advisor') && authState.role != AppRoles.serviceAdvisor) return '/';
        // Only customers should be able to access booking
        if (loc.startsWith('/booking') && authState.role != AppRoles.customer) return '/';
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
        path: '/booking',
        name: RouteNames.booking,
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: '/chatbot',
        name: RouteNames.chatbot,
        builder: (context, state) => const ChatbotPage(),
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

  ref.listen(userRoleProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
