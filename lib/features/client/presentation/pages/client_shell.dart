import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/data/datasources/notification_remote_data_source.dart';

class ClientShell extends StatelessWidget {
  final Widget child;

  const ClientShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteConstants.clientTickets)) return 1;
    if (location.startsWith(RouteConstants.clientNotifications)) return 2;
    if (location.startsWith(RouteConstants.clientProfile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteConstants.clientHome);
        break;
      case 1:
        context.go(RouteConstants.clientTickets);
        break;
      case 2:
        context.go(RouteConstants.clientNotifications);
        break;
      case 3:
        context.go(RouteConstants.clientProfile);
        break;
    }
  }

  Widget _alertsIcon({required bool active, required int unread}) {
    final icon = Icon(active ? Icons.notifications : Icons.notifications_outlined);
    if (unread <= 0) return icon;
    return Badge(
      backgroundColor: AppColors.error,
      label: Text(
        unread > 99 ? '99+' : '$unread',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeCubit>(); // rebuild nav bar colors on theme toggle
    final selectedIndex = _calculateSelectedIndex(context);
    final authState = context.watch<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : null;

    Widget buildNav(int unread) {
      return BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: _alertsIcon(active: false, unread: unread),
            activeIcon: _alertsIcon(active: true, unread: unread),
            label: unread > 0 ? (unread == 1 ? '1 new' : '$unread new') : 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.elevated,
        ),
        child: userId == null || userId.isEmpty
            ? buildNav(0)
            : StreamBuilder<int>(
                stream: NotificationRemoteDataSource().streamUnreadCount(userId),
                builder: (context, snapshot) {
                  return buildNav(snapshot.data ?? 0);
                },
              ),
      ),
    );
  }
}
