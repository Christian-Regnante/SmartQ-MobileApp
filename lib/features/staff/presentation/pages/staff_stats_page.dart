import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../tickets/data/models/ticket_model.dart';

class StaffStatsPage extends StatefulWidget {
  const StaffStatsPage({super.key});

  @override
  State<StaffStatsPage> createState() => _StaffStatsPageState();
}

class _StaffStatsPageState extends State<StaffStatsPage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final serviceId = user?.serviceId ?? (user?.serviceIds?.isNotEmpty == true ? user!.serviceIds!.first : null);

    if (serviceId == null || serviceId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Counter Performance'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'No service desk assigned to this staff account.')),
      );
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Counter Performance'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseConstants.ticketsCollection)
              .where('serviceId', isEqualTo: serviceId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingWidget(message: 'Calculating today\'s stats...');
            }

            final allDocs = snapshot.data?.docs ?? [];
            final allTickets = allDocs.map((doc) => TicketModel.fromFirestore(doc)).toList();

            // Filter today's completed tickets
            final todayCompleted = allTickets.where((t) {
              if (t.status.value != 'done' && t.status.value != 'completed') return false;
              final comp = t.completedAt ?? t.createdAt;
              return comp.isAfter(startOfDay);
            }).toList();

            final servedTodayCount = todayCompleted.length;

            // Compute Average Service Time for today's completed tickets
            double totalServiceMinutes = 0;
            int countWithTimes = 0;

            for (final t in todayCompleted) {
              if (t.calledAt != null && t.completedAt != null) {
                final diff = t.completedAt!.difference(t.calledAt!).inSeconds / 60.0;
                if (diff > 0) {
                  totalServiceMinutes += diff;
                  countWithTimes++;
                }
              }
            }

            final avgServiceTimeStr = countWithTimes > 0
                ? '${(totalServiceMinutes / countWithTimes).toStringAsFixed(1)}m'
                : '---';

            // Filter today's skipped & cancelled tickets
            final skippedTodayCount = allTickets.where((t) {
              return (t.status.value == 'skipped') && t.createdAt.isAfter(startOfDay);
            }).length;

            final cancelledTodayCount = allTickets.where((t) {
              return (t.status.value == 'cancelled') && t.createdAt.isAfter(startOfDay);
            }).length;

            // Sort recent served tickets by completedAt / createdAt descending
            final recentServed = List<TicketModel>.from(todayCompleted)
              ..sort((a, b) {
                final aTime = a.completedAt ?? a.createdAt;
                final bTime = b.completedAt ?? b.createdAt;
                return bTime.compareTo(aTime);
              });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assigned Service Desk ID: $serviceId',
                    style: const TextStyle(fontSize: 12, color: AppColors.outline),
                  ),
                  const SizedBox(height: 20),

                  // Stat Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                    children: [
                      StatCard(
                        label: 'Served Today',
                        value: '$servedTodayCount',
                        icon: Icons.check_circle_outline_rounded,
                        valueColor: AppColors.success,
                      ),
                      StatCard(
                        label: 'Avg Service Time',
                        value: avgServiceTimeStr,
                        icon: Icons.timer_outlined,
                        valueColor: AppColors.primary,
                      ),
                      StatCard(
                        label: 'Skipped Today',
                        value: '$skippedTodayCount',
                        icon: Icons.person_off_outlined,
                        valueColor: AppColors.error,
                      ),
                      StatCard(
                        label: 'Cancelled Today',
                        value: '$cancelledTodayCount',
                        icon: Icons.cancel_outlined,
                        valueColor: Colors.deepOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Served History
                  const Text(
                    'Recent Served Customers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (recentServed.isEmpty) ...[
                    const AppEmptyWidget(
                      title: 'No Completed Tickets Today',
                      message: 'Completed tickets served today will appear here.',
                      icon: Icons.history_rounded,
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentServed.length > 10 ? 10 : recentServed.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ticket = recentServed[index];
                        final compTime = ticket.completedAt ?? ticket.createdAt;
                        final timeStr = DateFormat('hh:mm a').format(compTime);

                        int durationMins = 0;
                        if (ticket.calledAt != null && ticket.completedAt != null) {
                          durationMins = ticket.completedAt!.difference(ticket.calledAt!).inMinutes;
                          if (durationMins < 1) durationMins = 1;
                        }

                        return NeumorphicCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ticket.ticketNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.serviceName ?? 'Service Desk',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                durationMins > 0 ? '${durationMins}m' : 'Completed',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
