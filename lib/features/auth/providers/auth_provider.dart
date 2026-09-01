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

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRoleState>((ref) {
  final authState = ref.watch(authStateProvider);
  return UserRoleNotifier(authState.value);
});

class UserRoleNotifier extends StateNotifier<UserRoleState> {
  final User? _user;

  UserRoleNotifier(this._user) : super(UserRoleState(isLoading: true)) {
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_user == null) {
      state = UserRoleState(isLoading: false, role: null);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
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
