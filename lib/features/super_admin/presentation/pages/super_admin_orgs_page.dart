import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminOrgsPage extends StatefulWidget {
  const SuperAdminOrgsPage({super.key});

  @override
  State<SuperAdminOrgsPage> createState() => _SuperAdminOrgsPageState();
}

class _SuperAdminOrgsPageState extends State<SuperAdminOrgsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().loadMasterDashboard();
  }

  void _showAddOrgDialog() {
    final cubit = context.read<SuperAdminCubit>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Kigali, Rwanda');
    final emailCtrl = TextEditingController();
    String selectedSector = 'Healthcare';

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register New Institution'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Organization Name *'),
                        validator: (v) => FormValidators.required(v, 'Organization name'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description (optional)'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: locCtrl,
                        decoration: const InputDecoration(labelText: 'Location / Address *'),
                        validator: (v) => FormValidators.required(v, 'Location'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Official Email *'),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSector,
                        decoration: const InputDecoration(labelText: 'Sector *'),
                        items: const [
                          DropdownMenuItem(value: 'Healthcare', child: Text('Healthcare')),
                          DropdownMenuItem(value: 'Banking & Financial', child: Text('Banking & Financial')),
                          DropdownMenuItem(value: 'Government e-Services', child: Text('Government e-Services')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSector = val);
                        },
                        validator: (v) => FormValidators.dropdownRequired(v, 'sector'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    cubit.addOrganization(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      location: locCtrl.text.trim(),
                      address: locCtrl.text.trim(),
                      phoneNumber: '+250788000111',
                      email: emailCtrl.text.trim(),
                      sector: selectedSector,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Register'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditOrgDialog(OrganizationEntity org) {
    final cubit = context.read<SuperAdminCubit>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: org.name);
    final descCtrl = TextEditingController(text: org.description ?? '');
    final locCtrl = TextEditingController(text: org.location);
    final emailCtrl = TextEditingController(text: org.email ?? '');
    bool isActive = org.isActive;
    String selectedSector = org.sector;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Organization'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Organization Name *'),
                        validator: (v) => FormValidators.required(v, 'Organization name'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description (optional)'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: locCtrl,
                        decoration: const InputDecoration(labelText: 'Location / Address *'),
                        validator: (v) => FormValidators.required(v, 'Location'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Official Email *'),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSector,
                        decoration: const InputDecoration(labelText: 'Sector *'),
                        items: const [
                          DropdownMenuItem(value: 'Healthcare', child: Text('Healthcare')),
                          DropdownMenuItem(value: 'Banking & Financial', child: Text('Banking & Financial')),
                          DropdownMenuItem(value: 'Government e-Services', child: Text('Government e-Services')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSector = val);
                        },
                        validator: (v) => FormValidators.dropdownRequired(v, 'sector'),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Operational Status'),
                        subtitle: Text(isActive ? 'Active' : 'Inactive / Deactivated'),
                        value: isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setDialogState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    cubit.updateOrganization(
                      id: org.id,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      location: locCtrl.text.trim(),
                      address: locCtrl.text.trim(),
                      phoneNumber: org.phoneNumber ?? '+250788000111',
                      email: emailCtrl.text.trim(),
                      isActive: isActive,
                      sector: selectedSector,
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

  void _confirmDeleteOrg(OrganizationEntity org) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Organization'),
        content: Text(
          'Are you sure you want to delete ${org.name}? This will remove the institution and disassociate assigned admins and services.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<SuperAdminCubit>().deleteOrganization(org.id);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Registered Institutions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            onPressed: _showAddOrgDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<SuperAdminCubit, SuperAdminState>(
            builder: (context, state) {
              if (state is SuperAdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading registered institutions...');
              }
              if (state is SuperAdminLoadedState) {
                if (state.organizations.isEmpty) {
                  return AppEmptyWidget(
                    title: 'No Institutions Found',
                    message: 'No institutions registered in Firebase yet.',
                    icon: Icons.apartment_outlined,
                    actionText: 'Register Institution',
                    onAction: _showAddOrgDialog,
                  );
                }
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
                              Expanded(
                                child: Text(
                                  org.name,
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
                                    onPressed: () => _showEditOrgDialog(org),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                    onPressed: () => _confirmDeleteOrg(org),
                                  ),
                                  Switch(
                                    value: org.isActive,
                                    activeThumbColor: AppColors.success,
                                    onChanged: (val) {
                                      context.read<SuperAdminCubit>().toggleOrganizationStatus(org.id, val);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            org.description ?? 'No description provided.',
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Location: ${org.location}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (org.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  org.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: org.isActive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricChip(Icons.medical_services_outlined, 'Services: ${org.serviceCount}'),
                              _buildMetricChip(Icons.people_outline_rounded, 'Staff: ${org.staffCount}'),
                              _buildMetricChip(Icons.admin_panel_settings_outlined, 'Admin: ${org.adminName ?? "Unassigned"}'),
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

  Widget _buildMetricChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
      ],
    );
  }
}
