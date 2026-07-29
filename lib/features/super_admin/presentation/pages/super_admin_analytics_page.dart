import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/national_analytics_entity.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminAnalyticsPage extends StatefulWidget {
  const SuperAdminAnalyticsPage({super.key});

  @override
  State<SuperAdminAnalyticsPage> createState() => _SuperAdminAnalyticsPageState();
}

class _SuperAdminAnalyticsPageState extends State<SuperAdminAnalyticsPage> {
  static const _sectorColors = <String, Color>{
    'Healthcare': Color(0xFF7C4DFF),
    'Banking & Financial': Color(0xFF2E7D32),
    'Government e-Services': Color(0xFFE65100),
    'Other': Color(0xFF546E7A),
  };

  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().loadMasterDashboard();
  }

  String _formatCount(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  Color _colorForSector(String label, int index) {
    return _sectorColors[label] ??
        [
          AppColors.primary,
          AppColors.success,
          Colors.deepOrange,
          Colors.teal,
          Colors.purple,
        ][index % 5];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('National Queue Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SuperAdminCubit, SuperAdminState>(
          builder: (context, state) {
            if (state is SuperAdminLoadingState || state is SuperAdminInitialState) {
              return const AppLoadingWidget(message: 'Loading national analytics...');
            }
            if (state is SuperAdminErrorState) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<SuperAdminCubit>().loadMasterDashboard(),
              );
            }
            if (state is! SuperAdminLoadedState) {
              return const SizedBox.shrink();
            }

            final analytics = state.analytics;
            final avgWait = analytics.avgWaitMinutes;
            final avgWaitLabel = avgWait == 0
                ? '0 min'
                : '${avgWait.toStringAsFixed(avgWait >= 10 ? 0 : 1)} min';
            final slaLabel = '${analytics.platformSlaPercent.toStringAsFixed(
              analytics.platformSlaPercent >= 99.95 ? 2 : 1,
            )}%';

            return RefreshIndicator(
              onRefresh: () => context.read<SuperAdminCubit>().loadMasterDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rwanda National Infrastructure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live queue metrics from ${analytics.registeredOrganizations} registered '
                      'organization${analytics.registeredOrganizations == 1 ? '' : 's'}'
                      ' (${analytics.activeOrganizations} active)',
                      style: TextStyle(fontSize: 13, color: AppColors.outline),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.2,
                      children: [
                        StatCard(
                          label: 'Total Customers Today',
                          value: _formatCount(analytics.customersToday),
                          icon: Icons.groups_rounded,
                          valueColor: AppColors.primary,
                        ),
                        StatCard(
                          label: 'Active Counters',
                          value: _formatCount(analytics.activeCounters),
                          icon: Icons.meeting_room_outlined,
                          valueColor: AppColors.success,
                        ),
                        StatCard(
                          label: 'Avg National Wait',
                          value: avgWaitLabel,
                          icon: Icons.timer_outlined,
                          valueColor: Colors.deepOrange,
                        ),
                        StatCard(
                          label: 'Platform SLA',
                          value: slaLabel,
                          icon: Icons.verified_rounded,
                          valueColor: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    NeumorphicCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queue Distribution by Sector',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            analytics.customersToday > 0
                                ? 'Based on today\'s tickets across registered organizations'
                                : 'Based on registered organization sectors (no tickets today yet)',
                            style: TextStyle(fontSize: 12, color: AppColors.outline),
                          ),
                          const SizedBox(height: 16),
                          if (analytics.sectorShares.isEmpty)
                            Text(
                              'No organizations registered yet.',
                              style: TextStyle(color: AppColors.outline),
                            )
                          else
                            ..._buildSectorRows(analytics.sectorShares),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSectorRows(List<SectorShare> shares) {
    final widgets = <Widget>[];
    for (var i = 0; i < shares.length; i++) {
      final share = shares[i];
      final color = _colorForSector(share.label, i);
      final pct = (share.fraction * 100).clamp(0, 100);
      final pctLabel = '${pct.toStringAsFixed(pct >= 10 || pct == 0 ? 0 : 1)}%';
      widgets.add(
        _buildSectorRow(
          '${share.label} (${share.orgCount} org${share.orgCount == 1 ? '' : 's'})',
          pctLabel,
          color,
          share.fraction.clamp(0.0, 1.0),
        ),
      );
      if (i < shares.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Widget _buildSectorRow(String title, String percentage, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              percentage,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.outlineVariant,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
