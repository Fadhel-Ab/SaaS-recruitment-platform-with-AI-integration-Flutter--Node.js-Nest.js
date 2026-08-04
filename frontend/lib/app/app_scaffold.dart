import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_event.dart';
import 'package:frontend/features/auth/bloc/auth_state.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';
import 'package:frontend/features/search/data/search_repository.dart';
import 'package:frontend/features/search/manager_search_delegate.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 700;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final selectedIndex = _selectedIndex(context, user?.role);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isPhone ? 'TalentAI' : 'TalentAI',
              overflow: TextOverflow.ellipsis,
            ),
            titleSpacing: isPhone ? 12 : null,
            actions: [
              if (user?.role == UserRole.manager)
                IconButton(
                  tooltip: 'Search jobs and candidates',
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: ManagerSearchDelegate(
                      context.read<SearchRepository>(),
                    ),
                  ),
                ),
              if (user?.role == UserRole.manager && !isPhone)
                IconButton(
                  tooltip: 'View job listings',
                  icon: const Icon(Icons.travel_explore_outlined),
                  onPressed: () => context.push('/jobs'),
                ),
              PopupMenuButton<String>(
                tooltip: 'User menu',
                icon: const Icon(Icons.account_circle_outlined),
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  } else if (value == 'view-jobs') {
                    context.push('/jobs');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(user?.email ?? 'User'),
                  ),
                  const PopupMenuDivider(),
                  if (user?.role == UserRole.manager)
                    const PopupMenuItem(
                      value: 'view-jobs',
                      child: ListTile(
                        leading: Icon(Icons.travel_explore_outlined),
                        title: Text('View Job Listings'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: isPhone
              ? child
              : Row(
                  children: [
                    // Desktop & Laptop Navigation Sidebar
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) =>
                          _go(context, index, user?.role),
                      labelType: NavigationRailLabelType.all,
                      selectedIconTheme: const IconThemeData(
                        color: Color(0xFF4F46E5),
                      ),
                      selectedLabelTextStyle: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                      destinations: [
                        if (user?.role == UserRole.manager)
                          const NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard_rounded),
                            label: Text('Dashboard'),
                          ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.work_outline),
                          selectedIcon: const Icon(Icons.work_rounded),
                          label: Text(
                            user?.role == UserRole.manager ? 'My Jobs' : 'Jobs',
                          ),
                        ),
                        if (user?.role == UserRole.manager)
                          const NavigationRailDestination(
                            icon: Icon(Icons.add_circle_outline),
                            selectedIcon: Icon(Icons.add_circle_rounded),
                            label: Text('Post Job'),
                          ),
                        if (user?.role == UserRole.manager)
                          const NavigationRailDestination(
                            icon: Icon(Icons.groups_outlined),
                            selectedIcon: Icon(Icons.groups_rounded),
                            label: Text('Candidates'),
                          ),
                        if (user?.role == UserRole.manager)
                          const NavigationRailDestination(
                            icon: Icon(Icons.schedule_outlined),
                            selectedIcon: Icon(Icons.schedule_rounded),
                            label: Text('Manager Time'),
                          ),
                        if (user != null && user.role != UserRole.manager)
                          const NavigationRailDestination(
                            icon: Icon(Icons.assignment_outlined),
                            selectedIcon: Icon(Icons.assignment),
                            label: Text('My Applications'),
                          ),
                      ],
                    ),
                    const VerticalDivider(
                      thickness: 1,
                      width: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    Expanded(child: child),
                  ],
                ),
          bottomNavigationBar: isPhone
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      _go(context, index, user?.role),
                  destinations: [
                    if (user?.role == UserRole.manager)
                      const NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        label: 'Dashboard',
                      ),
                    NavigationDestination(
                      icon: const Icon(Icons.work_outline),
                      label: user?.role == UserRole.manager
                          ? 'My Jobs'
                          : 'Jobs',
                    ),
                    if (user?.role == UserRole.manager)
                      const NavigationDestination(
                        icon: Icon(Icons.add_circle_outline),
                        label: 'Post',
                      ),
                    if (user?.role == UserRole.manager)
                      const NavigationDestination(
                        icon: Icon(Icons.groups_outlined),
                        label: 'Candidates',
                      ),
                    if (user?.role == UserRole.manager)
                      const NavigationDestination(
                        icon: Icon(Icons.schedule_outlined),
                        label: 'Time',
                      ),
                    if (user != null && user.role != UserRole.manager)
                      const NavigationDestination(
                        icon: Icon(Icons.assignment_outlined),
                        label: 'Applications',
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  int _selectedIndex(BuildContext context, UserRole? role) {
    final location = GoRouterState.of(context).uri.path;
    if (role == UserRole.manager) {
      if (location.startsWith('/dashboard')) return 0;
      if (location.startsWith('/manager/create-job')) return 2;
      if (location.startsWith('/manager/candidates')) return 3;
      if (location.startsWith('/manager/availability')) return 4;
      // /manager/jobs and its applicant/detail sub-routes fall through here.
      return 1;
    }
    if (location.startsWith('/my-applications')) return 1;
    return 0;
  }

  void _go(BuildContext context, int index, UserRole? role) {
    if (role == UserRole.manager) {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/manager/jobs');
          break;
        case 2:
          context.go('/manager/create-job');
          break;
        case 3:
          context.go('/manager/candidates');
          break;
        default:
          context.go('/manager/availability');
      }
    } else {
      context.go(index == 0 ? '/jobs' : '/my-applications');
    }
  }
}
