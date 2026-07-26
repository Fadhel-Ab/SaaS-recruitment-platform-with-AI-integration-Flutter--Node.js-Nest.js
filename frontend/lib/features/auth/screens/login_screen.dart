import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (state.user?.role == UserRole.manager) {
            context.go('/dashboard');
          } else {
            context.go('/candidate');
          }
        }

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Login failed')),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextField(
                  controller: emailController,

                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,

                  obscureText: true,

                  decoration: const InputDecoration(labelText: 'Password'),
                ),

                const SizedBox(height: 24),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                            },
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
