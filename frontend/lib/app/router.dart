import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/bloc/application_bloc.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/applications/screens/application_screen.dart';
import 'package:frontend/features/auth/screens/dashboard_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/jobs/bloc/job_details_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_event.dart';
import 'package:frontend/features/jobs/bloc/jobs_bloc.dart';
import 'package:frontend/features/jobs/bloc/jobs_event.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';
import 'package:frontend/features/jobs/screens/job_details_screen.dart';
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
    GoRoute(
      path: '/jobs/:shareToken',

      builder: (context, state) {
        final token = state.pathParameters['shareToken']!;

        return BlocProvider(
          create: (context) =>
              JobDetailsBloc(context.read<JobsRepository>())
                ..add(LoadJobDetails(token)),

          child: JobDetailsScreen(shareToken: token),
        );
      },
    ),
    GoRoute(
      path: '/apply/:shareToken',

      builder: (context, state) {
        final shareToken = state.pathParameters['shareToken']!;

        return BlocProvider(
          create: (context) =>
              ApplicationBloc(context.read<ApplicationRepository>()),
          child: ApplicationScreen(shareToken: shareToken),
        );
      },
    ),
  ],
);
