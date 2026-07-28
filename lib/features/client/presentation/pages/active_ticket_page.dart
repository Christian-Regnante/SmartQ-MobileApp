import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../../tickets/presentation/bloc/ticket_bloc.dart';
import '../../../tickets/presentation/bloc/ticket_event.dart';
import '../../../tickets/presentation/bloc/ticket_state.dart';

class ActiveTicketPage extends StatefulWidget {
  final String ticketId;

  const ActiveTicketPage({super.key, required this.ticketId});

  @override
  State<ActiveTicketPage> createState() => _ActiveTicketPageState();
}

class _ActiveTicketPageState extends State<ActiveTicketPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TicketBloc>().add(StreamActiveTicketEvent(authState.user.id));
    }
  }

  void _onCancelSubmitted(String? activeTicketId) {
    final ticketBloc = context.read<TicketBloc>();
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : null;
    final targetTicketId = (activeTicketId != null && activeTicketId.isNotEmpty)
        ? activeTicketId
        : widget.ticketId;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Ticket?'),
        content: const Text('Are you sure you want to leave this queue? Your ticket will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Ticket'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ticketBloc.add(CancelTicketSubmittedEvent(ticketId: targetTicketId, userId: userId));

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket successfully cancelled and deleted.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.go(RouteConstants.clientHome);
              }
            },
            child: const Text('Cancel Ticket', style: TextStyle(color: AppColors.error)),
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
        title: const Text('My Ticket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(RouteConstants.clientHome),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            if (state is TicketLoadingState) {
              return const AppLoadingWidget(message: 'Processing ticket action...');
            }

            final activeTicket = (state is TicketActiveState) ? state.activeTicket : null;

            if (activeTicket == null) {
              return AppEmptyWidget(
                title: 'No Active Ticket',
                message: 'You currently have no active tickets in any queue.',
                icon: Icons.confirmation_number_outlined,
                actionText: 'Browse Organizations',
                onAction: () => context.go(RouteConstants.clientOrganizations),
              );
            }

            final ticketNumber = activeTicket.ticketNumber;
            final orgName = activeTicket.organizationName ?? 'Organization';
            final serviceName = activeTicket.serviceName ?? 'Service Desk';
            final peopleAhead = activeTicket.position;
            final waitMinutes = activeTicket.estimatedWaitMinutes;
            final counter = activeTicket.counterNumber ?? 'Counter Desk';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    orgName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceName,
                    style: const TextStyle(fontSize: 14, color: AppColors.outline),
                  ),
                  const SizedBox(height: 24),
                  NeumorphicCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Text(
                          ticketNumber,
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'YOUR TICKET',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activeTicket.status.toDisplayString().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$peopleAhead',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const Text(
                                  'People Ahead',
                                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                              ],
                            ),
                            Container(height: 36, width: 1, color: AppColors.outlineVariant),
                            Column(
                              children: [
                                Text(
                                  '$waitMinutes min',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'Estimated Wait',
                                  style: TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Currently Serving Card
                  NeumorphicCard(
                    borderRadius: 20,
                    backgroundColor: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Currently Serving',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.outline,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                counter,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  NeumorphicButton(
                    text: 'Cancel Ticket',
                    type: NeumorphicButtonType.danger,
                    onPressed: () => _onCancelSubmitted(activeTicket.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
