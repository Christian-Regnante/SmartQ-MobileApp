enum UserRole {
  client('client'),
  staff('staff'),
  orgAdmin('org_admin'),
  superAdmin('super_admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.client;
    final clean = roleStr.trim().toLowerCase();
    switch (clean) {
      case 'staff':
        return UserRole.staff;
      case 'org_admin':
      case 'orgadmin':
        return UserRole.orgAdmin;
      case 'super_admin':
      case 'superadmin':
        return UserRole.superAdmin;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}
