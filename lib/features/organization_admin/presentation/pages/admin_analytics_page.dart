import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/admin_cubit.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.organizationId != null) {
      context.read<AdminCubit>().loadDashboard(authState.user.organizationId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final orgId = user?.organizationId;

    if (orgId == null || orgId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Organization Analytics'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'No organization assigned to this account.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Organization Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              if (state is AdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading live analytics...');
              }
              if (state is AdminLoadedState) {
                final services = state.services;
                final staffCount = state.staffMembers.length;
                final activeServices = services.where((s) => s.isActive).length;
                final totalWaiting = services.fold<int>(0, (sum, s) => sum + s.currentQueueCount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Performance Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time metrics for Organization ID: $orgId',
                      style: TextStyle(fontSize: 12, color: AppColors.outline),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Real Stat Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.2,
                      children: [
                        StatCard(
                          label: 'Clients Waiting',
                          value: totalWaiting.toString(),
                          icon: Icons.people_outline_rounded,
                          valueColor: AppColors.primary,
                        ),
                        StatCard(
                          label: 'Active Desks',
                          value: '$activeServices / ${services.length}',
                          icon: Icons.medical_services_outlined,
                          valueColor: AppColors.success,
                        ),
                        StatCard(
                          label: 'Provisioned Staff',
                          value: staffCount.toString(),
                          icon: Icons.badge_outlined,
                          valueColor: Colors.deepOrange,
                        ),
                        const StatCard(
                          label: 'System Status',
                          value: '100%',
                          icon: Icons.check_circle_outline_rounded,
                          valueColor: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Service Desk Traffic Breakdown
                    Text(
                      'Service Desk Traffic Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (services.isEmpty) ...[
                      const AppEmptyWidget(
                        title: 'No Service Desks',
                        message: 'Create service desks to view traffic breakdown metrics.',
                        icon: Icons.insert_chart_outlined_rounded,
                      ),
                    ] else ...[
                      NeumorphicCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: services.map((service) {
                            final ratio = totalWaiting > 0 ? (service.currentQueueCount / totalWaiting) : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        Text('${service.counterNumber ?? "Desk"} • ${service.averageServiceTimeMinutes}m avg wait',
                                            style: TextStyle(fontSize: 11, color: AppColors.outline)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: ratio,
                                            backgroundColor: AppColors.outlineVariant,
                                            color: AppColors.primary,
                                            minHeight: 8,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${service.currentQueueCount}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                );
              }
              if (state is AdminErrorState) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<AdminCubit>().loadDashboard(orgId),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
