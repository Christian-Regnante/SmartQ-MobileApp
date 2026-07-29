import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().loadMasterDashboard();
  }

  void _showAddOrgDialog() {
    final cubit = context.read<SuperAdminCubit>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Kigali, Rwanda');
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Register New Institution'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Organization Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Location / Address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Official Email'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  cubit.addOrganization(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    location: locCtrl.text.trim(),
                    address: locCtrl.text.trim(),
                    phoneNumber: '+250 788 000 111',
                    email: emailCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Register Institution'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final superAdminName = authState is Authenticated ? authState.user.fullName : 'Super Admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SmartQ Master Portal'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Master Control Panel, $superAdminName 👑',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'National Multi-Tenant Queue Management Infrastructure',
                style: TextStyle(fontSize: 13, color: AppColors.outline),
              ),
              const SizedBox(height: 20),

              // Master Platform Dynamic Stats Grid
              BlocBuilder<SuperAdminCubit, SuperAdminState>(
                builder: (context, state) {
                  final orgCount = state is SuperAdminLoadedState ? state.organizations.length.toString() : '0';
                  final adminCount = state is SuperAdminLoadedState ? state.orgAdmins.length.toString() : '0';

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      StatCard(
                        label: 'Registered Orgs',
                        value: orgCount,
                        icon: Icons.apartment_rounded,
                        valueColor: AppColors.primary,
                      ),
                      StatCard(
                        label: 'National Tickets Today',
                        value: '0',
                        icon: Icons.confirmation_number_rounded,
                        valueColor: AppColors.success,
                      ),
                      const StatCard(
                        label: 'Platform Health',
                        value: '100%',
                        icon: Icons.health_and_safety_outlined,
                        valueColor: Colors.teal,
                      ),
                      StatCard(
                        label: 'Active Org Admins',
                        value: adminCount,
                        icon: Icons.admin_panel_settings_outlined,
                        valueColor: Colors.purple,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Bar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.domain_add_rounded),
                      label: Text('Register Institution'),
                      onPressed: _showAddOrgDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Registered Institutions Overview
              Text(
                'Registered Institutions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              BlocBuilder<SuperAdminCubit, SuperAdminState>(
                builder: (context, state) {
                  if (state is SuperAdminLoadingState) {
                    return const AppLoadingWidget(message: 'Loading master directory...');
                  }
                  if (state is SuperAdminLoadedState) {
                    if (state.organizations.isEmpty) {
                      return AppEmptyWidget(
                        title: 'No Institutions Registered',
                        message: 'Tap "Register Institution" above to register your first organization.',
                        icon: Icons.apartment_outlined,
                        actionText: 'Register Institution',
                        onAction: _showAddOrgDialog,
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.organizations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final org = state.organizations[index];
                        return NeumorphicCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.business_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      org.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      org.location,
                                      style: TextStyle(fontSize: 12, color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
