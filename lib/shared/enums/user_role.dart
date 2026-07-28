enum UserRole {
  client('client'),
  staff('staff'),
  orgAdmin('org_admin'),
  superAdmin('super_admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? roleStr) {
    switch (roleStr) {
      case 'staff':
        return UserRole.staff;
      case 'org_admin':
        return UserRole.orgAdmin;
      case 'super_admin':
        return UserRole.superAdmin;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}
