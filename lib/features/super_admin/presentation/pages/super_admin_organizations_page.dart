import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminOrganizationsPage extends StatefulWidget {
  const SuperAdminOrganizationsPage({super.key});

  @override
  State<SuperAdminOrganizationsPage> createState() => _SuperAdminOrganizationsPageState();
}

class _SuperAdminOrganizationsPageState extends State<SuperAdminOrganizationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().loadMasterDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Registered Institutions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<SuperAdminCubit, SuperAdminState>(
            builder: (context, state) {
              if (state is SuperAdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading institutions...');
              }
              if (state is SuperAdminLoadedState) {
                return ListView.separated(
                  itemCount: state.organizations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final org = state.organizations[index];
                    return NeumorphicCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                org.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Switch(
                                value: org.isActive,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) {
                                  context.read<SuperAdminCubit>().repository.toggleOrganizationStatus(org.id, val);
                                  context.read<SuperAdminCubit>().loadMasterDashboard();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            org.location,
                            style: TextStyle(fontSize: 13, color: AppColors.outline),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            org.description ?? 'No description provided.',
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Email: ${org.email}',
                                style: TextStyle(fontSize: 12, color: AppColors.outline),
                              ),
                              Text(
                                '${org.serviceCount} Services',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              if (state is SuperAdminErrorState) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<SuperAdminCubit>().loadMasterDashboard(),
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
