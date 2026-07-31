import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../cubit/admin_cubit.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
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
    final formKey = GlobalKey<FormState>();
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Service Name *'),
                          validator: (v) => FormValidators.required(v, 'Service name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Description (optional)'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: counterCtrl,
                          decoration: const InputDecoration(labelText: 'Counter / Station Number *'),
                          validator: (v) => FormValidators.required(v, 'Counter / station number'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: timeValCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Avg. Waiting Time *'),
                                validator: (v) => FormValidators.positiveNumber(v, 'Avg. waiting time'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: timeUnit,
                                decoration: const InputDecoration(labelText: 'Time Format *'),
                                items: const [
                                  DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                                  DropdownMenuItem(value: 'Hours', child: Text('Hours')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => timeUnit = val);
                                },
                                validator: (v) => FormValidators.dropdownRequired(v, 'time format'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final rawNum = double.parse(timeValCtrl.text.trim());
                    final minutes = timeUnit == 'Hours' ? (rawNum * 60).round() : rawNum.round();

                    cubit.addService(
                      organizationId: organizationId,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      counterNumber: counterCtrl.text.trim(),
                      averageServiceTimeMinutes: minutes,
                    );
                    Navigator.pop(ctx);
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

  void _showEditServiceDialog(String organizationId, ServiceEntity service) {
    final cubit = context.read<AdminCubit>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: service.name);
    final descCtrl = TextEditingController(text: service.description ?? '');
    final counterCtrl = TextEditingController(text: service.counterNumber ?? 'Counter 1');
    final timeValCtrl = TextEditingController(text: service.averageServiceTimeMinutes.toString());
    String timeUnit = 'Minutes';
    bool isActive = service.isActive;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Service Desk'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Service Name *'),
                          validator: (v) => FormValidators.required(v, 'Service name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Description (optional)'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: counterCtrl,
                          decoration: const InputDecoration(labelText: 'Counter / Station Number *'),
                          validator: (v) => FormValidators.required(v, 'Counter / station number'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: timeValCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Avg. Waiting Time *'),
                                validator: (v) => FormValidators.positiveNumber(v, 'Avg. waiting time'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: timeUnit,
                                decoration: const InputDecoration(labelText: 'Time Format *'),
                                items: const [
                                  DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                                  DropdownMenuItem(value: 'Hours', child: Text('Hours')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => timeUnit = val);
                                },
                                validator: (v) => FormValidators.dropdownRequired(v, 'time format'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Desk Status'),
                          subtitle: Text(isActive ? 'Active' : 'Inactive / Closed'),
                          value: isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setDialogState(() => isActive = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final rawNum = double.parse(timeValCtrl.text.trim());
                    final minutes = timeUnit == 'Hours' ? (rawNum * 60).round() : rawNum.round();

                    cubit.updateService(
                      organizationId: organizationId,
                      serviceId: service.id,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      counterNumber: counterCtrl.text.trim(),
                      averageServiceTimeMinutes: minutes,
                      isActive: isActive,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteService(String organizationId, String serviceId, String serviceName) {
    final cubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service Desk'),
        content: Text('Are you sure you want to permanently delete "$serviceName" from Firestore? Staff assignments will be cleaned up.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              cubit.deleteService(organizationId: organizationId, serviceId: serviceId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final orgId = user?.organizationId;

    if (orgId == null || orgId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Manage Services'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'No organization assigned to this account.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Service Desks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddServiceDialog(orgId),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              if (state is AdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading services...');
              }
              if (state is AdminLoadedState) {
                if (state.services.isEmpty) {
                  return AppEmptyWidget(
                    title: 'No Service Desks',
                    message: 'No service desks have been added yet.',
                    icon: Icons.medical_services_outlined,
                    actionText: 'Add Service Desk',
                    onAction: () => _showAddServiceDialog(orgId),
                  );
                }
                return ListView.separated(
                  itemCount: state.services.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    final counterName = service.counterNumber ?? 'Counter 1';

                    return NeumorphicCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () => _showEditServiceDialog(orgId, service),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                    onPressed: () => _confirmDeleteService(orgId, service.id, service.name),
                                  ),
                                  Switch(
                                    value: service.isActive,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: (val) {
                                      context.read<AdminCubit>().repository.toggleServiceStatus(
                                            orgId,
                                            service.id,
                                            val,
                                          );
                                      context.read<AdminCubit>().loadDashboard(orgId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            service.description ?? 'No description provided.',
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Counter: $counterName',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
                              ),
                              Text(
                                'Avg. Wait: ${service.averageServiceTimeMinutes} mins • ${service.currentQueueCount} Waiting',
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
