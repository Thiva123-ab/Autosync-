import 'dart:async';
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
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  UserRoleState build() {
    final user = ref.watch(authStateProvider).value;
    
    _subscription?.cancel();
    
    if (user == null) {
      return UserRoleState(isLoading: false, role: null);
    }
    
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        state = UserRoleState(isLoading: false, role: doc.data()?['role'] ?? AppRoles.customer);
      } else {
        state = UserRoleState(isLoading: false, role: AppRoles.customer);
      }
    }, onError: (_) {
      state = UserRoleState(isLoading: false, role: AppRoles.customer);
    });
    
    // Cleanup subscription on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return UserRoleState(isLoading: true);
  }
}

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRoleState>(() {
  return UserRoleNotifier();
});
