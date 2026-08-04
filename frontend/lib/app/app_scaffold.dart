import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_event.dart';
import 'package:frontend/features/auth/bloc/auth_state.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
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
              if (user == null)
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Log in'),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'User menu',
                  icon: const Icon(Icons.account_circle_outlined),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    } else if (value == 'view-jobs') {
                      context.push('/jobs');
                    } else if (value == 'phone') {
                      showDialog(
                        context: context,
                        builder: (_) => const _PhoneNumberDialog(),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(enabled: false, child: Text(user.email)),
                    const PopupMenuDivider(),
                    if (user.role == UserRole.manager) ...[
                      const PopupMenuItem(
                        value: 'view-jobs',
                        child: ListTile(
                          leading: Icon(Icons.travel_explore_outlined),
                          title: Text('View Job Listings'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'phone',
                        child: ListTile(
                          leading: Icon(Icons.phone_outlined),
                          title: Text('Phone Number'),
                        ),
                      ),
                    ],
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

class _PhoneNumberDialog extends StatefulWidget {
  const _PhoneNumberDialog();

  @override
  State<_PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<_PhoneNumberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AuthRepository>().updateProfile(
        '+973${_phoneController.text.trim()}',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number saved.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${friendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Phone Number'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: const InputDecoration(
            prefixText: '+973 ',
            hintText: '3XXX XXXX',
            helperText: 'Used for WhatsApp notifications, e.g. new applications.',
          ),
          validator: (v) {
            final digits = (v ?? '').trim();
            if (digits.length != 8) {
              return 'Enter a valid 8-digit Bahrain phone number';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
