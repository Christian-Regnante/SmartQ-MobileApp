import 'package:equatable/equatable.dart';
import '../../../../shared/enums/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final String? organizationId;
  final String? serviceId;
  final List<String>? serviceIds;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.organizationId,
    this.serviceId,
    this.serviceIds,
    this.photoUrl,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        role,
        organizationId,
        serviceId,
        serviceIds,
        photoUrl,
        isActive,
        createdAt,
      ];
}
