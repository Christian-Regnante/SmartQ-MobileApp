class RouteConstants {
  RouteConstants._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // Client Shell Routes
  static const String clientHome = '/client/home';
  static const String clientOrganizations = '/client/organizations';
  static const String clientServices = '/client/organizations/:orgId/services';
  static const String clientJoinQueue = '/client/organizations/:orgId/services/:serviceId/join';
  static const String clientActiveTicket = '/client/ticket/:ticketId';
  static const String clientTickets = '/client/tickets';
  static const String clientNotifications = '/client/notifications';
  static const String clientProfile = '/client/profile';

  // Staff Shell Routes
  static const String staffDashboard = '/staff/dashboard';
  static const String staffQueue = '/staff/queue';
  static const String staffStatistics = '/staff/statistics';
  static const String staffProfile = '/staff/profile';

  // Org Admin Shell Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminServices = '/admin/services';
  static const String adminStaff = '/admin/staff';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminProfile = '/admin/profile';

  // Super Admin Shell Routes
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String superAdminOrganizations = '/super-admin/organizations';
  static const String superAdminAdmins = '/super-admin/admins';
  static const String superAdminAnalytics = '/super-admin/analytics';
  static const String superAdminLogs = '/super-admin/logs';
  static const String superAdminProfile = '/super-admin/profile';
}
