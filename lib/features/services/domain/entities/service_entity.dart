import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String organizationId;
  final String name;
  final String? description;
  final String? counterNumber;
  final int averageServiceTimeMinutes;
  final bool isActive;
  final int currentQueueCount;

  const ServiceEntity({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    this.counterNumber,
    this.averageServiceTimeMinutes = 10,
    this.isActive = true,
    this.currentQueueCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        organizationId,
        name,
        description,
        counterNumber,
        averageServiceTimeMinutes,
        isActive,
        currentQueueCount,
      ];
}
