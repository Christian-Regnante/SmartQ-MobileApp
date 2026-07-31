import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminAdminsPage extends StatefulWidget {
  const SuperAdminAdminsPage({super.key});

  @override
  State<SuperAdminAdminsPage> createState() => _SuperAdminAdminsPageState();
}

class _SuperAdminAdminsPageState extends State<SuperAdminAdminsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().loadMasterDashboard();
  }

  void _showProvisionAdminDialog(List<OrganizationEntity> availableOrgs) {
    if (availableOrgs.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cannot Provision Admin'),
          content: const Text(
            'No registered institutions exist in the database. Please register an organization first before provisioning an Organization Admin.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final cubit = context.read<SuperAdminCubit>();
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Admin123!');
    final nameCtrl = TextEditingController();
    String selectedOrgId = availableOrgs.first.id;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Provision Org Administrator'),
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
                          decoration: const InputDecoration(labelText: 'Admin Email *'),
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
                          initialValue: selectedOrgId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Institution *',
                            border: OutlineInputBorder(),
                          ),
                          items: availableOrgs.map((org) {
                            return DropdownMenuItem<String>(
                              value: org.id,
                              child: Text(org.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedOrgId = val);
                            }
                          },
                          validator: (v) => FormValidators.dropdownRequired(v, 'institution'),
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
                    cubit.provisionAdmin(
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      fullName: nameCtrl.text.trim(),
                      organizationId: selectedOrgId,
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

  void _showEditAdminDialog(UserEntity admin, List<OrganizationEntity> availableOrgs) {
    final cubit = context.read<SuperAdminCubit>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: admin.fullName);
    final emailCtrl = TextEditingController(text: admin.email);
    String? selectedOrgId = admin.organizationId ?? (availableOrgs.isNotEmpty ? availableOrgs.first.id : null);
    bool isActive = admin.isActive;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Org Administrator'),
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
                          decoration: const InputDecoration(labelText: 'Admin Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 16),
                        if (availableOrgs.isNotEmpty)
                          DropdownButtonFormField<String>(
                            initialValue: selectedOrgId,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Institution *',
                              border: OutlineInputBorder(),
                            ),
                            items: availableOrgs.map((org) {
                              return DropdownMenuItem<String>(
                                value: org.id,
                                child: Text(org.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedOrgId = val);
                              }
                            },
                            validator: (v) => FormValidators.dropdownRequired(v, 'institution'),
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
                    cubit.updateAdmin(
                      adminId: admin.id,
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      organizationId: selectedOrgId,
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

  void _confirmDeleteAdmin(UserEntity admin) {
    final cubit = context.read<SuperAdminCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Org Administrator'),
        content: Text('Are you sure you want to delete ${admin.fullName}? This will remove the admin user and unassign their organization.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              cubit.deleteAdmin(adminId: admin.id, organizationId: admin.organizationId);
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
        title: const Text('Org Admin Directory'),
        centerTitle: true,
        actions: [
          BlocBuilder<SuperAdminCubit, SuperAdminState>(
            builder: (context, state) {
              final orgs = state is SuperAdminLoadedState ? state.organizations : <OrganizationEntity>[];
              return IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () => _showProvisionAdminDialog(orgs),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<SuperAdminCubit, SuperAdminState>(
            listener: (context, state) {
              if (state is SuperAdminErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
              }
            },
            builder: (context, state) {
              if (state is SuperAdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading org admins...');
              }
              if (state is SuperAdminLoadedState) {
                if (state.orgAdmins.isEmpty) {
                  return AppEmptyWidget(
                    title: 'No Org Admins Provisioned',
                    message: 'Tap + above to provision an administrator for a registered institution.',
                    icon: Icons.admin_panel_settings_outlined,
                    actionText: 'Provision Org Admin',
                    onAction: () => _showProvisionAdminDialog(state.organizations),
                  );
                }
                return ListView.separated(
                  itemCount: state.orgAdmins.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final admin = state.orgAdmins[index];

                    final matchingOrg = state.organizations.cast<OrganizationEntity>().firstWhere(
                          (org) => org.id == admin.organizationId,
                          orElse: () => OrganizationEntity(
                            id: admin.organizationId ?? '',
                            name: 'Unassigned Institution',
                            location: 'Unknown',
                            createdAt: DateTime.now(),
                          ),
                        );

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
                            child: Icon(Icons.security_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin.fullName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  admin.email,
                                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Org: ${matchingOrg.name}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                onPressed: () => _showEditAdminDialog(admin, state.organizations),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDeleteAdmin(admin),
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
