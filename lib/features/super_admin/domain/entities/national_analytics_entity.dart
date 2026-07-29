import 'package:equatable/equatable.dart';

class SectorShare extends Equatable {
  final String label;
  final double fraction;
  final int orgCount;

  const SectorShare({
    required this.label,
    required this.fraction,
    required this.orgCount,
  });

  @override
  List<Object?> get props => [label, fraction, orgCount];
}

class NationalAnalyticsEntity extends Equatable {
  final int customersToday;
  final int activeCounters;
  final double avgWaitMinutes;
  final double platformSlaPercent;
  final List<SectorShare> sectorShares;
  final int registeredOrganizations;
  final int activeOrganizations;

  const NationalAnalyticsEntity({
    required this.customersToday,
    required this.activeCounters,
    required this.avgWaitMinutes,
    required this.platformSlaPercent,
    required this.sectorShares,
    required this.registeredOrganizations,
    required this.activeOrganizations,
  });

  factory NationalAnalyticsEntity.empty() => const NationalAnalyticsEntity(
        customersToday: 0,
        activeCounters: 0,
        avgWaitMinutes: 0,
        platformSlaPercent: 100,
        sectorShares: [],
        registeredOrganizations: 0,
        activeOrganizations: 0,
      );

  @override
  List<Object?> get props => [
        customersToday,
        activeCounters,
        avgWaitMinutes,
        platformSlaPercent,
        sectorShares,
        registeredOrganizations,
        activeOrganizations,
      ];
}
