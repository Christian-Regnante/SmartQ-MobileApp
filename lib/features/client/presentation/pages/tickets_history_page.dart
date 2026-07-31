import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../shared/enums/ticket_status.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/domain/entities/cancelled_ticket_entity.dart';
import '../../../tickets/presentation/bloc/ticket_bloc.dart';
import '../../../tickets/presentation/bloc/ticket_event.dart';
import '../../../tickets/presentation/bloc/ticket_state.dart';

class TicketsHistoryPage extends StatefulWidget {
  const TicketsHistoryPage({super.key});

  @override
  State<TicketsHistoryPage> createState() => _TicketsHistoryPageState();
}

class _TicketsHistoryPageState extends State<TicketsHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TicketBloc>().add(StreamActiveTicketEvent(authState.user.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.done:
        return AppColors.success;
      case TicketStatus.serving:
      case TicketStatus.waiting:
        return AppColors.primary;
      case TicketStatus.cancelled:
      case TicketStatus.skipped:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Ticket History'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            final historyTickets = (state is TicketActiveState) ? state.historyTickets : <TicketEntity>[];
            final cancelledTickets = (state is TicketActiveState) ? state.cancelledTickets : <CancelledTicketEntity>[];

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 0: ALL
                _buildTicketsList(
                  historyTickets.where((t) => t.status == TicketStatus.done).toList(),
                  emptyTitle: 'No History Found',
                  emptyMessage: 'Completed queue tickets will appear here.',
                ),

                // TAB 1: COMPLETED
                _buildTicketsList(
                  historyTickets.where((t) => t.status == TicketStatus.done).toList(),
                  emptyTitle: 'No Completed Tickets',
                  emptyMessage: 'Tickets you have completed will be listed here.',
                ),

                // TAB 2: DEDICATED CANCELLED TICKETS COLLECTION
                _buildCancelledTicketsList(cancelledTickets),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketsList(
    List<TicketEntity> tickets, {
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (tickets.isEmpty) {
      return AppEmptyWidget(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.confirmation_number_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: tickets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt);

        return NeumorphicCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  ticket.ticketNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.serviceName ?? 'Service',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.organizationName ?? 'Organization',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.status.toDisplayString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelledTicketsList(List<CancelledTicketEntity> cancelledTickets) {
    if (cancelledTickets.isEmpty) {
      return const AppEmptyWidget(
        title: 'No Cancelled Tickets',
        message: 'Tickets that were cancelled by you or staff will be archived here.',
        icon: Icons.cancel_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: cancelledTickets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = cancelledTickets[index];
        final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.cancelledAt);

        return NeumorphicCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ticket.queueNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.organizationName ?? 'Organization',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.serviceName ?? 'Service Desk',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CANCELLED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cancelled on: $dateStr',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                    ),
                  ),
                  if (ticket.counterNumber != null && ticket.counterNumber!.isNotEmpty)
                    Text(
                      'Desk: ${ticket.counterNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                ],
              ),
              if (ticket.cancellationReason != null && ticket.cancellationReason!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Reason: ${ticket.cancellationReason}',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
