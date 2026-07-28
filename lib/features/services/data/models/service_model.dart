import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.organizationId,
    required super.name,
    super.description,
    super.counterNumber,
    super.averageServiceTimeMinutes,
    super.isActive,
    super.currentQueueCount,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [String? fallbackOrgId]) {
    final data = doc.data() ?? {};
    final orgId = data['organizationId'] as String? ?? fallbackOrgId ?? '';
    final avgMinutes = (data['waitingTime'] as num?)?.toInt() ??
        (data['averageServiceTime'] as num?)?.toInt() ??
        (data['averageServiceTimeMinutes'] as num?)?.toInt() ??
        10;

    return ServiceModel(
      id: doc.id,
      organizationId: orgId,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      counterNumber: data['counterNumber'] as String?,
      averageServiceTimeMinutes: avgMinutes,
      isActive: data['isActive'] as bool? ?? true,
      currentQueueCount: (data['currentQueueCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'counterNumber': counterNumber,
      'averageServiceTime': averageServiceTimeMinutes,
      'averageServiceTimeMinutes': averageServiceTimeMinutes,
      'waitingTime': averageServiceTimeMinutes,
      'isActive': isActive,
      'currentQueueCount': currentQueueCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
