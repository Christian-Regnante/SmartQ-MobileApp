import 'package:equatable/equatable.dart';

class OrganizationEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String location;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? logoUrl;
  final String? adminId;
  final String? adminName;
  final bool isActive;
  final int serviceCount;
  final int staffCount;
  final DateTime createdAt;

  const OrganizationEntity({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    this.address,
    this.phoneNumber,
    this.email,
    this.logoUrl,
    this.adminId,
    this.adminName,
    this.isActive = true,
    this.serviceCount = 0,
    this.staffCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        address,
        phoneNumber,
        email,
        logoUrl,
        adminId,
        adminName,
        isActive,
        serviceCount,
        staffCount,
        createdAt,
      ];
}
