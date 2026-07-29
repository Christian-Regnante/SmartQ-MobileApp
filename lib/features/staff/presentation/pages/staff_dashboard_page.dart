import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/staff_queue_bloc.dart';
import '../bloc/staff_queue_event.dart';
import '../bloc/staff_queue_state.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  bool _isCounterOpen = true;
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _initQueue();
  }

  void _initQueue() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      if (user.serviceIds != null && user.serviceIds!.isNotEmpty) {
        _selectedServiceId ??= user.serviceIds!.first;
        context.read<StaffQueueBloc>().add(
              InitStaffQueueEvent(
                serviceId: _selectedServiceId!,
                counterNumber: 'Counter Desk',
              ),
            );
      }
    }
  }

  void _onCallNext() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      final orgId = user.organizationId ?? '';
      final activeServiceId = _selectedServiceId ??
          ((user.serviceIds != null && user.serviceIds!.isNotEmpty)
              ? user.serviceIds!.first
              : '');

      if (activeServiceId.isNotEmpty) {
        context.read<StaffQueueBloc>().add(
              CallNextTicketSubmittedEvent(
                organizationId: orgId,
                serviceId: activeServiceId,
                staffId: user.id,
                counterNumber: 'Counter Desk',
              ),
            );
      }
    }
  }

  void _onCallSpecificTicket(String ticketId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      context.read<StaffQueueBloc>().add(
            CallSpecificTicketSubmittedEvent(
              ticketId: ticketId,
              staffId: user.id,
              counterNumber: 'Counter Desk',
            ),
          );
    }
  }

  void _onCancelServingTicket(String ticketId) {
    final authState = context.read<AuthBloc>().state;
    final staffId = authState is Authenticated ? authState.user.id : '';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel this ticket?'),
        content: const Text('This will remove the customer from the active queue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Serving'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<StaffQueueBloc>().add(
                    StaffCancelTicketSubmittedEvent(
                      ticketId: ticketId,
                      staffId: staffId,
                    ),
                  );
            },
            child: Text('Cancel Ticket', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final staffName = user?.fullName ?? 'Staff Member';
    final orgId = user?.organizationId;
    final assignedServiceIds = user?.serviceIds ?? <String>[];

    if (orgId == null || orgId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Staff Dashboard'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'No organization assigned to this staff account.')),
      );
    }

    if (_selectedServiceId == null && assignedServiceIds.isNotEmpty) {
      _selectedServiceId = assignedServiceIds.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Staff Service Desk'),
        centerTitle: true,
        actions: [
          Switch(
            value: _isCounterOpen,
            activeThumbColor: AppColors.success,
            onChanged: (val) {
              setState(() => _isCounterOpen = val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<StaffQueueBloc, StaffQueueState>(
          listener: (context, state) {
            if (state is StaffQueueFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final servingTicket = (state is StaffQueueActiveState) ? state.currentlyServing : null;
            final waitingQueue = (state is StaffQueueActiveState) ? state.waitingQueue : <dynamic>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Staff Greeting Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $staffName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Assigned Desks: ${assignedServiceIds.length} active service(s)',
                              style: TextStyle(fontSize: 12, color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_isCounterOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isCounterOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _isCounterOpen ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (assignedServiceIds.length > 1) ...[
                    Text(
                      'Select Active Service Desk:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedServiceId,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: assignedServiceIds.map((sId) {
                        return DropdownMenuItem<String>(
                          value: sId,
                          child: Text('Desk: $sId', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (newServiceId) {
                        if (newServiceId != null) {
                          setState(() {
                            _selectedServiceId = newServiceId;
                          });
                          context.read<StaffQueueBloc>().add(
                                InitStaffQueueEvent(
                                  serviceId: newServiceId,
                                  counterNumber: 'Counter Desk',
                                ),
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Currently Serving Card Section
                  NeumorphicCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'CURRENTLY SERVING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          servingTicket?.ticketNumber ?? '---',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: servingTicket != null ? AppColors.primary : AppColors.outline,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (servingTicket != null) ...[
                          Text(
                            servingTicket.organizationName ?? 'Organization',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            servingTicket.serviceName ?? 'Service Desk',
                            style: TextStyle(fontSize: 13, color: AppColors.outline),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Status: Being Served',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade900,
                                    side: BorderSide(color: Colors.amber.shade800),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.redo_rounded),
                                  label: const Text('Skip'),
                                  onPressed: () {
                                    context.read<StaffQueueBloc>().add(
                                          SkipTicketSubmittedEvent(servingTicket.id),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: BorderSide(color: AppColors.error),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: Text('Cancel'),
                                  onPressed: () => _onCancelServingTicket(servingTicket.id),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'No customer currently being served',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Action Button (Call Next Customer OR Complete Service)
                  if (servingTicket == null) ...[
                    NeumorphicButton(
                      text: 'Call Next Customer 🔔',
                      onPressed: (_isCounterOpen && waitingQueue.isNotEmpty) ? _onCallNext : null,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 22),
                        label: const Text(
                          'Complete Service',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          context.read<StaffQueueBloc>().add(
                                CompleteTicketSubmittedEvent(servingTicket.id),
                              );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Waiting Queue List Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waiting in Queue (${waitingQueue.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (servingTicket == null && waitingQueue.isNotEmpty)
                        TextButton(
                          onPressed: _isCounterOpen ? _onCallNext : null,
                          child: const Text('Call First in Line'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Single Serving Ticket Explanatory Protection Banner
                  if (servingTicket != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You are currently serving Queue #${servingTicket.ticketNumber}. Complete, skip, or cancel before calling another customer.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (waitingQueue.isEmpty) ...[
                    const AppEmptyWidget(
                      title: 'Queue is Empty',
                      message: 'No clients are currently waiting in line.',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: waitingQueue.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ticket = waitingQueue[index];
                        final canCallSpecific = _isCounterOpen && (servingTicket == null);

                        return NeumorphicCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
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
                                    ticket.ticketNumber,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    ticket.serviceName ?? 'Service Desk',
                                    style: TextStyle(fontSize: 12, color: AppColors.outline),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '${ticket.estimatedWaitMinutes}m wait',
                                style: TextStyle(fontSize: 12, color: AppColors.outline),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canCallSpecific ? AppColors.primary : Colors.grey.shade300,
                                  foregroundColor: canCallSpecific ? Colors.white : Colors.grey.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: canCallSpecific ? () => _onCallSpecificTicket(ticket.id) : null,
                                child: const Text(
                                  'Call',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
