import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/admin_cubit.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.organizationId != null) {
      context.read<AdminCubit>().loadDashboard(authState.user.organizationId!);
    }
  }

  void _showAddServiceDialog(String organizationId) {
    final cubit = context.read<AdminCubit>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final counterCtrl = TextEditingController(text: 'Counter 1');
    final timeValCtrl = TextEditingController(text: '15');
    String timeUnit = 'Minutes';

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Service Desk'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Service Name (e.g. Consultation)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: counterCtrl,
                        decoration: const InputDecoration(labelText: 'Counter / Station Number'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: timeValCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Avg. Waiting Time'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: timeUnit,
                              decoration: const InputDecoration(labelText: 'Time Format'),
                              items: const [
                                DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                                DropdownMenuItem(value: 'Hours', child: Text('Hours')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => timeUnit = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      final rawNum = double.tryParse(timeValCtrl.text.trim()) ?? 15;
                      final minutes = timeUnit == 'Hours' ? (rawNum * 60).round() : rawNum.round();

                      cubit.addService(
                        organizationId: organizationId,
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        counterNumber: counterCtrl.text.trim(),
                        averageServiceTimeMinutes: minutes,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Create Service'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final adminName = user?.fullName ?? 'Org Admin';
    final orgId = user?.organizationId;

    if (orgId == null || orgId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Organization Admin'), centerTitle: true),
        body: const Center(
          child: AppErrorWidget(message: 'No organization assigned to this account.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Organization Control Panel'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $adminName 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Text(
                'Organization Operations & Queue Control',
                style: TextStyle(fontSize: 13, color: AppColors.outline),
              ),
              const SizedBox(height: 20),

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
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Service Desk'),
                      onPressed: () => _showAddServiceDialog(orgId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Active Service Desks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoadingState) {
                    return const AppLoadingWidget(message: 'Loading org metrics...');
                  }
                  if (state is AdminLoadedState) {
                    if (state.services.isEmpty) {
                      return AppEmptyWidget(
                        title: 'No Service Desks Created',
                        message: 'Tap "Add Service Desk" above to create your first service.',
                        icon: Icons.design_services_outlined,
                        actionText: 'Add Service Desk',
                        onAction: () => _showAddServiceDialog(orgId),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.services.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final service = state.services[index];
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
                                child: const Icon(Icons.medical_services_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${service.counterNumber} • Avg ${service.averageServiceTimeMinutes}m',
                                      style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${service.currentQueueCount} Waiting',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
            ],
          ),
        ),
      ),
    );
  }
}
