import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../cubit/admin_cubit.dart';

class AdminStaffPage extends StatefulWidget {
  const AdminStaffPage({super.key});

  @override
  State<AdminStaffPage> createState() => _AdminStaffPageState();
}

class _AdminStaffPageState extends State<AdminStaffPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.organizationId != null) {
      context.read<AdminCubit>().loadDashboard(authState.user.organizationId!);
    }
  }

  void _showProvisionStaffDialog(String organizationId, List<ServiceEntity> availableServices) {
    if (availableServices.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cannot Provision Staff'),
          content: const Text(
            'No active service desks exist in the database for your organization. Please create at least one real service desk first before provisioning staff members.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final cubit = context.read<AdminCubit>();
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Staff123!');
    final nameCtrl = TextEditingController();
    String selectedServiceId = availableServices.first.id;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Provision Staff Member'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Full Name *'),
                          validator: (v) => FormValidators.required(v, 'Full name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Staff Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passCtrl,
                          decoration: const InputDecoration(labelText: 'Initial Password *'),
                          validator: FormValidators.password,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedServiceId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Service Desk *',
                            border: OutlineInputBorder(),
                          ),
                          items: availableServices.map((service) {
                            return DropdownMenuItem<String>(
                              value: service.id,
                              child: Text(
                                '${service.name} (${service.counterNumber ?? 'Desk'})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedServiceId = val;
                              });
                            }
                          },
                          validator: (v) => FormValidators.dropdownRequired(v, 'service desk'),
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
                    cubit.provisionStaff(
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      fullName: nameCtrl.text.trim(),
                      organizationId: organizationId,
                      serviceId: selectedServiceId,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Provision Account'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditStaffDialog(String organizationId, UserEntity staff, List<ServiceEntity> availableServices) {
    final cubit = context.read<AdminCubit>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: staff.fullName);
    final emailCtrl = TextEditingController(text: staff.email);
    String selectedServiceId = staff.serviceId ?? (availableServices.isNotEmpty ? availableServices.first.id : '');
    bool isActive = staff.isActive;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Staff Member'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Full Name *'),
                          validator: (v) => FormValidators.required(v, 'Full name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Staff Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 16),
                        if (availableServices.isNotEmpty)
                          DropdownButtonFormField<String>(
                            initialValue: selectedServiceId.isNotEmpty ? selectedServiceId : availableServices.first.id,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Service Desk *',
                              border: OutlineInputBorder(),
                            ),
                            items: availableServices.map((service) {
                              return DropdownMenuItem<String>(
                                value: service.id,
                                child: Text(
                                  '${service.name} (${service.counterNumber ?? 'Desk'})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedServiceId = val;
                                });
                              }
                            },
                            validator: (v) => FormValidators.dropdownRequired(v, 'service desk'),
                          ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Account Status'),
                          subtitle: Text(isActive ? 'Active' : 'Disabled'),
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
                    cubit.updateStaff(
                      organizationId: organizationId,
                      staffId: staff.id,
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      serviceId: selectedServiceId,
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

  void _confirmDeleteStaff(String organizationId, UserEntity staff) {
    final cubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: Text('Are you sure you want to delete ${staff.fullName}? This action will remove the staff profile from Firestore.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              cubit.deleteStaff(organizationId: organizationId, staffId: staff.id);
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
        appBar: AppBar(title: const Text('Staff Roster'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'No organization assigned to this account.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Roster Management'),
        centerTitle: true,
        actions: [
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final services = state is AdminLoadedState ? state.services : <ServiceEntity>[];
              return IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () => _showProvisionStaffDialog(orgId, services),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<AdminCubit, AdminState>(
            listener: (context, state) {
              if (state is AdminErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
              }
            },
            builder: (context, state) {
              if (state is AdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading staff roster...');
              }
              if (state is AdminLoadedState) {
                if (state.staffMembers.isEmpty) {
                  return AppEmptyWidget(
                    title: 'No Staff Accounts Provisioned',
                    message: 'Tap + above to provision a staff account.',
                    icon: Icons.people_outline_rounded,
                    actionText: 'Provision Staff Member',
                    onAction: () => _showProvisionStaffDialog(orgId, state.services),
                  );
                }
                return ListView.separated(
                  itemCount: state.staffMembers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final staff = state.staffMembers[index];

                    final matchingService = state.services.cast<ServiceEntity>().firstWhere(
                          (s) => s.id == staff.serviceId || (staff.serviceIds != null && staff.serviceIds!.contains(s.id)),
                          orElse: () => ServiceEntity(
                            id: staff.serviceId ?? '',
                            organizationId: orgId,
                            name: 'Service Desk',
                          ),
                        );
                    final assignedDeskName = matchingService.name;

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
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff.fullName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  staff.email,
                                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Assigned Desk: $assignedDeskName',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                onPressed: () => _showEditStaffDialog(orgId, staff, state.services),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDeleteStaff(orgId, staff),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
