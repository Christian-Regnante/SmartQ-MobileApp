import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../services/presentation/cubit/service_cubit.dart';

class ServicesPage extends StatefulWidget {
  final String organizationId;

  const ServicesPage({super.key, required this.organizationId});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().loadServices(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select a Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<ServiceCubit, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const AppLoadingWidget(message: 'Loading services...');
              }
              if (state is ServiceLoaded) {
                return ListView.separated(
                  itemCount: state.services.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return NeumorphicCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            service.description ?? 'No service description.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 16, color: AppColors.outline),
                              const SizedBox(width: 6),
                              Text(
                                'Avg. service time: ${service.averageServiceTimeMinutes} min',
                                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.people_outline_rounded, size: 16, color: AppColors.outline),
                              const SizedBox(width: 6),
                              Text(
                                'Current queue: ${service.currentQueueCount} people',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          NeumorphicButton(
                            text: 'Join Queue',
                            onPressed: () {
                              context.push(
                                '/client/organizations/${widget.organizationId}/services/${service.id}/join',
                                extra: service,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              if (state is ServiceEmpty) {
                return const AppEmptyWidget(
                  title: 'No Services Available',
                  message: 'This organization has no active services right now.',
                );
              }
              if (state is ServiceError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<ServiceCubit>().loadServices(widget.organizationId),
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
