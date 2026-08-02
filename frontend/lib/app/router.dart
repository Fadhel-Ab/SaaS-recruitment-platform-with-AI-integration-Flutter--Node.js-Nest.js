import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/app_scaffold.dart';
import 'package:frontend/features/applications/bloc/application_bloc.dart';
import 'package:frontend/features/applications/bloc/application_detail_bloc.dart';
import 'package:frontend/features/applications/bloc/application_detail_event.dart';
import 'package:frontend/features/applications/bloc/application_event.dart';
import 'package:frontend/features/applications/bloc/job_applicants_bloc.dart';
import 'package:frontend/features/applications/bloc/job_applicants_event.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/applications/screens/application_detail_screen.dart';
import 'package:frontend/features/applications/screens/application_screen.dart';
import 'package:frontend/features/applications/screens/job_applicants_screen.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_state.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/auth/screens/register_screen.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_event.dart';
import 'package:frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:frontend/features/jobs/bloc/create_job_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_event.dart';
import 'package:frontend/features/jobs/bloc/jobs_bloc.dart';
import 'package:frontend/features/jobs/bloc/jobs_event.dart';
import 'package:frontend/features/jobs/bloc/manager_jobs_bloc.dart';
import 'package:frontend/features/jobs/bloc/manager_jobs_event.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';
import 'package:frontend/features/jobs/screens/create_job_screen.dart';
import 'package:frontend/features/jobs/screens/job_details_screen.dart';
import 'package:frontend/features/jobs/screens/jobs_screen.dart';
import 'package:frontend/features/jobs/screens/manager_jobs_screen.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthBloc authBloc) => GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  redirect: (context, state) {
    final authState = authBloc.state;
    final path = state.uri.path;
    final isAuthPage = path == '/login' || path == '/register';
    final isChecking = authState.status == AuthStatus.initial || authState.status == AuthStatus.loading;

    if (isChecking) return null;
    if (authState.status != AuthStatus.authenticated) return isAuthPage ? null : '/login';
    if (isAuthPage) return authState.user?.role == UserRole.manager ? '/dashboard' : '/jobs';
    if (path.startsWith('/manager') || path == '/dashboard') {
      return authState.user?.role == UserRole.manager ? null : '/jobs';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => BlocProvider(create: (_) => DashboardBloc(context.read<DashboardRepository>())..add(LoadDashboard()), child: const DashboardScreen())),
        GoRoute(path: '/jobs', builder: (context, state) => BlocProvider(create: (context) => JobsBloc(context.read<JobsRepository>())..add(const LoadJobs()), child: const JobsScreen())),
        GoRoute(path: '/jobs/:shareToken', builder: (context, state) { final token = state.pathParameters['shareToken']!; return BlocProvider(create: (context) => JobDetailsBloc(context.read<JobsRepository>())..add(LoadJobDetails(token)), child: JobDetailsScreen(shareToken: token)); }),
        GoRoute(path: '/apply/:shareToken', builder: (context, state) { final shareToken = state.pathParameters['shareToken']!; return BlocProvider(create: (context) { final bloc = ApplicationBloc(context.read<ApplicationRepository>(), context.read<JobsRepository>()); bloc.add(LoadApplicationJob(shareToken)); return bloc; }, child: ApplicationScreen(shareToken: shareToken)); }),
        GoRoute(path: '/manager/jobs', builder: (context, state) => BlocProvider(create: (_) => ManagerJobsBloc(context.read<JobsRepository>())..add(LoadManagerJobs()), child: ManagerJobsScreen())),
        GoRoute(path: '/manager/create-job', builder: (context, state) => BlocProvider(create: (_) => CreateJobBloc(context.read<JobsRepository>()), child: const CreateJobScreen())),
        GoRoute(path: '/manager/jobs/:jobId/applicants', builder: (context, state) { final jobId = state.pathParameters['jobId']!; return BlocProvider(create: (context) => JobApplicantsBloc(context.read<ApplicationRepository>())..add(LoadJobApplicants(jobId)), child: JobApplicantsScreen(jobId: jobId)); }),
        GoRoute(path: '/manager/applications/:applicationId', builder: (context, state) { final applicationId = state.pathParameters['applicationId']!; return BlocProvider(create: (context) => ApplicationDetailBloc(context.read<ApplicationRepository>())..add(LoadApplicationDetail(applicationId)), child: ApplicationDetailScreen(applicationId: applicationId)); }),
      ],
    ),
  ],
);
