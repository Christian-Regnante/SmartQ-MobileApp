import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    super.address,
    super.phoneNumber,
    super.email,
    super.logoUrl,
    super.adminId,
    super.adminName,
    super.isActive,
    super.serviceCount,
    super.staffCount,
    required super.createdAt,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrganizationModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      location: data['location'] as String? ?? 'Kigali',
      address: data['address'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      email: data['email'] as String?,
      logoUrl: data['logoUrl'] as String?,
      adminId: data['adminId'] as String?,
      adminName: data['adminName'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      serviceCount: (data['serviceCount'] as num?)?.toInt() ?? 0,
      staffCount: (data['staffCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? address,
    String? phoneNumber,
    String? email,
    String? logoUrl,
    String? adminId,
    String? adminName,
    bool? isActive,
    int? serviceCount,
    int? staffCount,
    DateTime? createdAt,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      isActive: isActive ?? this.isActive,
      serviceCount: serviceCount ?? this.serviceCount,
      staffCount: staffCount ?? this.staffCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'logoUrl': logoUrl,
      'adminId': adminId,
      'adminName': adminName,
      'isActive': isActive,
      'serviceCount': serviceCount,
      'staffCount': staffCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
