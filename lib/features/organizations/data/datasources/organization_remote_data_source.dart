import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/organization_model.dart';

abstract class OrganizationRemoteDataSource {
  Future<List<OrganizationModel>> getActiveOrganizations({String? searchQuery});
  Future<OrganizationModel?> getOrganizationById(String id);
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrganizationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<OrganizationModel>> getActiveOrganizations({String? searchQuery}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      List<OrganizationModel> orgs = [];

      for (final doc in snapshot.docs) {
        final baseOrg = OrganizationModel.fromFirestore(doc);

        int realServiceCount = 0;
        try {
          final servicesSnap = await _firestore
              .collection('services')
              .where('organizationId', isEqualTo: doc.id)
              .where('isActive', isEqualTo: true)
              .get();
          realServiceCount = servicesSnap.docs.length;
        } catch (_) {}

        orgs.add(baseOrg.copyWith(serviceCount: realServiceCount));
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        orgs = orgs.where((org) {
          return org.name.toLowerCase().contains(query) ||
              org.location.toLowerCase().contains(query);
        }).toList();
      }

      return orgs;
    } catch (e) {
      throw ServerException('Failed to fetch organizations: ${e.toString()}');
    }
  }

  @override
  Future<OrganizationModel?> getOrganizationById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return OrganizationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
