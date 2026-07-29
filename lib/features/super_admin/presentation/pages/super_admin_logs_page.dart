import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubit/super_admin_cubit.dart';

class SuperAdminLogsPage extends StatefulWidget {
  const SuperAdminLogsPage({super.key});

  @override
  State<SuperAdminLogsPage> createState() => _SuperAdminLogsPageState();
}

class _SuperAdminLogsPageState extends State<SuperAdminLogsPage> {
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
        title: const Text('System Audit Logs'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<SuperAdminCubit, SuperAdminState>(
            builder: (context, state) {
              if (state is SuperAdminLoadingState) {
                return const AppLoadingWidget(message: 'Loading activity logs...');
              }
              if (state is SuperAdminLoadedState) {
                if (state.logs.isEmpty) {
                  return const AppEmptyWidget(
                    title: 'No Audit Logs Recorded',
                    message: 'System audit logs will appear here as administrative actions occur.',
                    icon: Icons.history_toggle_off_rounded,
                  );
                }
                return ListView.separated(
                  itemCount: state.logs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = state.logs[index];
                    final action = log['action'] as String;
                    final details = log['details'] as String;
                    final time = log['timestamp'] as DateTime;
                    final timeStr = DateFormat('MMM dd • hh:mm a').format(time);

                    return NeumorphicCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.history_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  details,
                                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(fontSize: 11, color: AppColors.outline),
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
