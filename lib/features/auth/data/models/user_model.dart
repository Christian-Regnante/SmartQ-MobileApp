import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../shared/enums/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    required super.role,
    super.organizationId,
    super.serviceId,
    super.serviceIds,
    super.photoUrl,
    super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawServiceIds = (data['serviceIds'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    final rawServiceId = data['serviceId'] as String? ?? (rawServiceIds?.isNotEmpty == true ? rawServiceIds!.first : null);
    final finalServiceIds = rawServiceIds ?? (rawServiceId != null ? [rawServiceId] : null);

    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      role: UserRole.fromString(data['role'] as String?),
      organizationId: data['organizationId'] as String?,
      serviceId: rawServiceId,
      serviceIds: finalServiceIds,
      photoUrl: data['photoUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final effectiveServiceId = serviceId ?? (serviceIds?.isNotEmpty == true ? serviceIds!.first : null);
    final effectiveServiceIds = serviceIds ?? (effectiveServiceId != null ? [effectiveServiceId] : null);

    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.value,
      'organizationId': organizationId,
      'serviceId': effectiveServiceId,
      'serviceIds': effectiveServiceIds,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
