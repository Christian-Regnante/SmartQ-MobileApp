import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String? ticketId;
  final String? organizationId;
  final String? serviceId;
  final String type; // 'queue', 'alert', 'success', 'info'
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.ticketId,
    this.organizationId,
    this.serviceId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      ticketId: data['ticketId'] as String?,
      organizationId: data['organizationId'] as String?,
      serviceId: data['serviceId'] as String?,
      type: data['type'] as String? ?? 'info',
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ticketId': ticketId,
      'organizationId': organizationId,
      'serviceId': serviceId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
