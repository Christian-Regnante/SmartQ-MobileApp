import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_input.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../tickets/presentation/bloc/ticket_bloc.dart';
import '../../../tickets/presentation/bloc/ticket_event.dart';
import '../../../tickets/presentation/bloc/ticket_state.dart';

class JoinQueuePage extends StatefulWidget {
  final String organizationId;
  final String serviceId;
  final ServiceEntity? serviceEntity;

  const JoinQueuePage({
    super.key,
    required this.organizationId,
    required this.serviceId,
    this.serviceEntity,
  });

  @override
  State<JoinQueuePage> createState() => _JoinQueuePageState();
}

class _JoinQueuePageState extends State<JoinQueuePage> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _phoneController.text = authState.user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onJoinConfirmed() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {

      context.read<TicketBloc>().add(
            JoinQueueSubmittedEvent(
              userId: authState.user.id,
              organizationId: widget.organizationId,
              serviceId: widget.serviceId,
              phoneNumber: _phoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.serviceEntity?.name ?? 'Service Desk';
    final currentQueue = widget.serviceEntity?.currentQueueCount ?? 0;
    final avgWait = widget.serviceEntity?.averageServiceTimeMinutes ?? 15;
    final estimatedWait = currentQueue * avgWait;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Join Queue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<TicketBloc, TicketState>(
          listener: (context, state) {
            if (state is TicketActiveState && state.activeTicket != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ticket created successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/client/ticket/${state.activeTicket!.id}');
            }
            if (state is TicketFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TicketLoadingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Confirm details to join digital queue',
                    style: TextStyle(fontSize: 14, color: AppColors.outline),
                  ),
                  const SizedBox(height: 24),
                  NeumorphicCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Current Queue', style: TextStyle(color: AppColors.outline)),
                            Text(
                              '$currentQueue people',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                        Divider(height: 24, color: AppColors.outlineVariant),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Wait', style: TextStyle(color: AppColors.outline)),
                            Text(
                              '~$estimatedWait minutes',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        NeumorphicInput(
                          controller: _phoneController,
                          labelText: 'Contact Phone Number',
                          hintText: '+250 7XX XXX XXX',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.outline),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'By joining this queue, you agree to receive SMS/In-App notifications when your turn is approaching.',
                          style: TextStyle(fontSize: 12, color: AppColors.outline, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        NeumorphicButton(
                          text: 'Confirm & Join Queue',
                          isLoading: isLoading,
                          onPressed: _onJoinConfirmed,
                        ),
                      ],
                    ),
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
