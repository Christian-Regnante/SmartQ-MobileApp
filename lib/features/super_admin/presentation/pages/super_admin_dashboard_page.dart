import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
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
                  child: const Text('Register Institution'),
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
                  final orgs = state is SuperAdminLoadedState ? state.organizations : const [];
                  final admins = state is SuperAdminLoadedState ? state.orgAdmins : const [];
                  final activeOrgs = orgs.where((o) => o.isActive).toList();
                  final activeOrgIds = activeOrgs.map((o) => o.id).toSet();
                  final activeAdminCount = admins
                      .where((a) => a.organizationId != null && activeOrgIds.contains(a.organizationId))
                      .length;
                  final orgHealth = orgs.isEmpty
                      ? 100
                      : ((activeOrgs.length / orgs.length) * 100).round();
                  final ticketsToday = state is SuperAdminLoadedState
                      ? state.analytics.customersToday.toString()
                      : '0';

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      StatCard(
                        label: 'Active Orgs',
                        value: orgs.isEmpty ? '0' : '${activeOrgs.length} / ${orgs.length}',
                        icon: Icons.apartment_rounded,
                        valueColor: AppColors.primary,
                      ),
                      StatCard(
                        label: 'National Tickets Today',
                        value: ticketsToday,
                        icon: Icons.confirmation_number_rounded,
                        valueColor: AppColors.success,
                      ),
                      StatCard(
                        label: 'Platform Health',
                        value: '$orgHealth%',
                        icon: Icons.health_and_safety_outlined,
                        valueColor: Colors.teal,
                      ),
                      StatCard(
                        label: 'Active Org Admins',
                        value: activeAdminCount.toString(),
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
                                  color: (org.isActive ? AppColors.success : AppColors.error)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  org.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: org.isActive ? AppColors.success : AppColors.error,
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
