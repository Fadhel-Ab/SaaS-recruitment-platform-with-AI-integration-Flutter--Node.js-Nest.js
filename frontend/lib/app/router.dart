import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/screens/dashboard_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/jobs/bloc/jobs_bloc.dart';
import 'package:frontend/features/jobs/bloc/jobs_event.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';
import 'package:frontend/features/jobs/screens/jobs_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    GoRoute(
      path: '/login',

      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/dashboard',

      builder: (context, state) {
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/jobs',

      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              JobsBloc(context.read<JobsRepository>())..add(const LoadJobs()),
          child: const JobsScreen(),
        );
      },
    ),
  ],
);
