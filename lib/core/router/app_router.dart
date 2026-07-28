import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../services/service_locator.dart';
import '../../shared/enums/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

// Splash & Onboarding & Auth
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

// Shared Notifications & Profile Pages
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

// Client Feature Pages & Shell
import '../../features/client/presentation/pages/client_shell.dart';
import '../../features/client/presentation/pages/client_home_page.dart';
import '../../features/client/presentation/pages/organizations_page.dart';
import '../../features/client/presentation/pages/services_page.dart';
import '../../features/client/presentation/pages/join_queue_page.dart';
import '../../features/client/presentation/pages/active_ticket_page.dart';
import '../../features/client/presentation/pages/tickets_history_page.dart';

// Staff Feature Pages & Shell
import '../../features/staff/presentation/pages/staff_shell.dart';
import '../../features/staff/presentation/pages/staff_dashboard_page.dart';
import '../../features/staff/presentation/pages/staff_stats_page.dart';
import '../../features/staff/presentation/bloc/staff_queue_bloc.dart';

// Organization Admin Feature Pages & Shell
import '../../features/organization_admin/presentation/pages/admin_shell.dart';
import '../../features/organization_admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/organization_admin/presentation/pages/admin_services_page.dart';
import '../../features/organization_admin/presentation/pages/admin_staff_page.dart';
import '../../features/organization_admin/presentation/pages/admin_analytics_page.dart';
import '../../features/organization_admin/presentation/cubit/admin_cubit.dart';

// Super Admin Feature Pages & Shell
import '../../features/super_admin/presentation/pages/super_admin_shell.dart';
import '../../features/super_admin/presentation/pages/super_admin_dashboard_page.dart';
import '../../features/super_admin/presentation/pages/super_admin_organizations_page.dart';
import '../../features/super_admin/presentation/pages/super_admin_admins_page.dart';
import '../../features/super_admin/presentation/pages/super_admin_analytics_page.dart';
import '../../features/super_admin/presentation/pages/super_admin_logs_page.dart';
import '../../features/super_admin/presentation/cubit/super_admin_cubit.dart';

// BLoCs / Cubits for Providers
import '../../features/organizations/presentation/cubit/organization_cubit.dart';
import '../../features/services/presentation/cubit/service_cubit.dart';
import '../../features/services/domain/entities/service_entity.dart';
import '../../features/tickets/presentation/bloc/ticket_bloc.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: _AuthListenable(authBloc),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isSplash = state.matchedLocation == RouteConstants.splash;
      final isOnboarding = state.matchedLocation == RouteConstants.onboarding;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (isSplash) return null;

      if (authState is Unauthenticated) {
        if (isAuthRoute || isOnboarding) return null;
        return RouteConstants.login;
      }

      if (authState is Authenticated) {
        final role = authState.user.role;
        if (isAuthRoute || isOnboarding || isSplash) {
          switch (role) {
            case UserRole.staff:
              return RouteConstants.staffDashboard;
            case UserRole.orgAdmin:
              return RouteConstants.adminDashboard;
            case UserRole.superAdmin:
              return RouteConstants.superAdminDashboard;
            case UserRole.client:
              return RouteConstants.clientHome;
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Client Experience Routes
      ShellRoute(
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<OrganizationCubit>()),
              BlocProvider(create: (_) => sl<TicketBloc>()),
            ],
            child: ClientShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstants.clientHome,
            builder: (context, state) => const ClientHomePage(),
          ),
          GoRoute(
            path: RouteConstants.clientOrganizations,
            builder: (context, state) => const OrganizationsPage(),
          ),
          GoRoute(
            path: RouteConstants.clientTickets,
            builder: (context, state) => const TicketsHistoryPage(),
          ),
          GoRoute(
            path: RouteConstants.clientNotifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteConstants.clientProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Standalone Client Detail Screens
      GoRoute(
        path: RouteConstants.clientServices,
        builder: (context, state) {
          final orgId = state.pathParameters['orgId'] ?? 'king_faisal_hospital';
          return BlocProvider(
            create: (_) => sl<ServiceCubit>(),
            child: ServicesPage(organizationId: orgId),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.clientJoinQueue,
        builder: (context, state) {
          final orgId = state.pathParameters['orgId'] ?? '';
          final serviceId = state.pathParameters['serviceId'] ?? '';
          final serviceEntity = state.extra as ServiceEntity?;

          return BlocProvider(
            create: (_) => sl<TicketBloc>(),
            child: JoinQueuePage(
              organizationId: orgId,
              serviceId: serviceId,
              serviceEntity: serviceEntity,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.clientActiveTicket,
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId'] ?? '';
          return BlocProvider(
            create: (_) => sl<TicketBloc>(),
            child: ActiveTicketPage(ticketId: ticketId),
          );
        },
      ),

      // Staff Experience Shell
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<StaffQueueBloc>(),
            child: StaffShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstants.staffDashboard,
            builder: (context, state) => const StaffDashboardPage(),
          ),
          GoRoute(
            path: RouteConstants.staffQueue,
            builder: (context, state) => const StaffDashboardPage(),
          ),
          GoRoute(
            path: RouteConstants.staffStatistics,
            builder: (context, state) => const StaffStatsPage(),
          ),
          GoRoute(
            path: RouteConstants.staffProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Org Admin Shell
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<AdminCubit>(),
            child: AdminShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstants.adminDashboard,
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: RouteConstants.adminServices,
            builder: (context, state) => const AdminServicesPage(),
          ),
          GoRoute(
            path: RouteConstants.adminStaff,
            builder: (context, state) => const AdminStaffPage(),
          ),
          GoRoute(
            path: RouteConstants.adminAnalytics,
            builder: (context, state) => const AdminAnalyticsPage(),
          ),
          GoRoute(
            path: RouteConstants.adminProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Super Admin Shell
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<SuperAdminCubit>(),
            child: SuperAdminShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstants.superAdminDashboard,
            builder: (context, state) => const SuperAdminDashboardPage(),
          ),
          GoRoute(
            path: RouteConstants.superAdminOrganizations,
            builder: (context, state) => const SuperAdminOrganizationsPage(),
          ),
          GoRoute(
            path: RouteConstants.superAdminAdmins,
            builder: (context, state) => const SuperAdminAdminsPage(),
          ),
          GoRoute(
            path: RouteConstants.superAdminAnalytics,
            builder: (context, state) => const SuperAdminAnalyticsPage(),
          ),
          GoRoute(
            path: RouteConstants.superAdminLogs,
            builder: (context, state) => const SuperAdminLogsPage(),
          ),
          GoRoute(
            path: RouteConstants.superAdminProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _AuthListenable extends ChangeNotifier {
  final AuthBloc bloc;
  _AuthListenable(this.bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
