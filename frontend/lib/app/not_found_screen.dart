import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/data/models/user_role.dart';

/// Shown for any URL that doesn't match a route — most commonly a mistyped
/// or stale web address — instead of go_router's default error dump.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  String _homePath(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return '/login';
    return user.role == UserRole.manager ? '/dashboard' : '/jobs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '404',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "We couldn't find the page you're looking for.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(_homePath(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Take me home',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
