import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServicesForOrganization(String organizationId);
  Future<ServiceModel?> getServiceById(String organizationId, String serviceId);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final FirebaseFirestore _firestore;

  ServiceRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ServiceModel>> getServicesForOrganization(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('organizationId', isEqualTo: organizationId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, organizationId))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load services: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel?> getServiceById(String organizationId, String serviceId) async {
    try {
      final doc = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();
      if (!doc.exists) return null;
      return ServiceModel.fromFirestore(doc, organizationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
