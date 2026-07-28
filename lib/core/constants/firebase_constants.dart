class FirebaseConstants {
  FirebaseConstants._();

  // Firestore Top-Level Collections
  static const String usersCollection = 'users';
  static const String organizationsCollection = 'organizations';
  static const String ticketsCollection = 'tickets';
  static const String notificationsCollection = 'notifications';
  static const String adminLogsCollection = 'admin_logs';
  static const String systemCollection = 'system';

  // Firestore Subcollections
  static const String servicesSubcollection = 'services';
  static const String staffSubcollection = 'staff';
  static const String analyticsSubcollection = 'analytics';

  // Cloud Functions Names
  static const String fnJoinQueue = 'joinQueue';
  static const String fnCallNextTicket = 'callNextTicket';
  static const String fnCompleteTicket = 'completeTicket';
  static const String fnSkipTicket = 'skipTicket';
  static const String fnCancelTicket = 'cancelTicket';
}
