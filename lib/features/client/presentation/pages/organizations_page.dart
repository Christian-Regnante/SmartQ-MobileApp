import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../organizations/presentation/cubit/organization_cubit.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrganizationCubit>().loadOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Organizations'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              NeumorphicInput(
                controller: _searchController,
                hintText: 'Search by organization or city...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.outline),
                onChanged: (query) {
                  context.read<OrganizationCubit>().loadOrganizations(searchQuery: query);
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<OrganizationCubit, OrganizationState>(
                  builder: (context, state) {
                    if (state is OrganizationLoading) {
                      return const AppLoadingWidget(message: 'Searching organizations...');
                    }
                    if (state is OrganizationLoaded) {
                      return ListView.separated(
                        itemCount: state.organizations.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final org = state.organizations[index];
                          return NeumorphicCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.apartment_rounded,
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            org.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            org.location,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  org.description ?? 'No description provided.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${org.serviceCount} Services Available',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        context.push('/client/organizations/${org.id}/services');
                                      },
                                      child: const Text('View Services'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    if (state is OrganizationEmpty) {
                      return const AppEmptyWidget(
                        title: 'No Organizations Found',
                        message: 'Try adjusting your search terms.',
                      );
                    }
                    if (state is OrganizationError) {
                      return AppErrorWidget(
                        message: state.message,
                        onRetry: () => context.read<OrganizationCubit>().loadOrganizations(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
