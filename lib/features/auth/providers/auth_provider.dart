import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_roles.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class UserRoleState {
  final bool isLoading;
  final String? role;

  UserRoleState({this.isLoading = false, this.role});
}

class UserRoleNotifier extends Notifier<UserRoleState> {
  @override
  UserRoleState build() {
    final user = ref.watch(authStateProvider).value;
    
    // Defer the async fetch so we can return the initial loading state immediately
    Future.microtask(() => _fetchUserRole(user));
    
    return UserRoleState(isLoading: true);
  }

  Future<void> _fetchUserRole(User? user) async {
    if (user == null) {
      state = UserRoleState(isLoading: false, role: null);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = UserRoleState(isLoading: false, role: doc.data()?['role'] ?? AppRoles.customer);
      } else {
        state = UserRoleState(isLoading: false, role: AppRoles.customer);
      }
    } catch (e) {
      state = UserRoleState(isLoading: false, role: AppRoles.customer);
    }
  }
}

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRoleState>(() {
  return UserRoleNotifier();
});
