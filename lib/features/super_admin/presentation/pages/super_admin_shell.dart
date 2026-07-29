import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_cubit.dart';

class SuperAdminShell extends StatelessWidget {
  final Widget child;

  const SuperAdminShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteConstants.superAdminOrganizations)) return 1;
    if (location.startsWith(RouteConstants.superAdminAdmins)) return 2;
    if (location.startsWith(RouteConstants.superAdminAnalytics)) return 3;
    if (location.startsWith(RouteConstants.superAdminLogs)) return 4;
    if (location.startsWith(RouteConstants.superAdminProfile)) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteConstants.superAdminDashboard);
        break;
      case 1:
        context.go(RouteConstants.superAdminOrganizations);
        break;
      case 2:
        context.go(RouteConstants.superAdminAdmins);
        break;
      case 3:
        context.go(RouteConstants.superAdminAnalytics);
        break;
      case 4:
        context.go(RouteConstants.superAdminLogs);
        break;
      case 5:
        context.go(RouteConstants.superAdminProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeCubit>(); // rebuild nav bar colors on theme toggle
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.elevated,
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.outline,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Orgs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account_outlined),
              activeIcon: Icon(Icons.supervisor_account),
              label: 'Admins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
