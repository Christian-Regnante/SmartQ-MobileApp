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
    super.sector,
    super.isActive,
    super.serviceCount,
    super.staffCount,
    required super.createdAt,
  });

  static String resolveSector({
    String? sector,
    required String name,
    String? description,
  }) {
    final explicit = sector?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final text = '$name ${description ?? ''}'.toLowerCase();
    if (text.contains('hospital') ||
        text.contains('clinic') ||
        text.contains('health') ||
        text.contains('chub') ||
        text.contains('faisal') ||
        text.contains('medical')) {
      return 'Healthcare';
    }
    if (text.contains('bank') || text.contains('financ') || text.contains('microfinance')) {
      return 'Banking & Financial';
    }
    if (text.contains('gov') ||
        text.contains('ministr') ||
        text.contains('e-service') ||
        text.contains('municip') ||
        text.contains('rra') ||
        text.contains('rssb')) {
      return 'Government e-Services';
    }
    return 'Other';
  }

  factory OrganizationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final name = data['name'] as String? ?? '';
    final description = data['description'] as String?;
    return OrganizationModel(
      id: doc.id,
      name: name,
      description: description,
      location: data['location'] as String? ?? 'Kigali',
      address: data['address'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      email: data['email'] as String?,
      logoUrl: data['logoUrl'] as String?,
      adminId: data['adminId'] as String?,
      adminName: data['adminName'] as String?,
      sector: resolveSector(
        sector: data['sector'] as String?,
        name: name,
        description: description,
      ),
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
    String? sector,
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
      sector: sector ?? this.sector,
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
      'sector': sector,
      'isActive': isActive,
      'serviceCount': serviceCount,
      'staffCount': staffCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
