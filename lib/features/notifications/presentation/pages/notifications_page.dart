import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationDataSource = NotificationRemoteDataSource();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : null;

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
        body: const Center(child: AppErrorWidget(message: 'Please sign in to view notifications.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await _notificationDataSource.markAllAsRead(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: _notificationDataSource.streamUserNotifications(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingWidget(message: 'Loading notifications...');
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return const AppEmptyWidget(
                title: 'No Notifications',
                message: 'You are all caught up! Queue updates will appear here in real-time.',
                icon: Icons.notifications_off_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif.isRead;
                final timeStr = DateFormat('MMM dd • hh:mm a').format(notif.createdAt);

                return NeumorphicCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  backgroundColor: isRead ? AppColors.surface : AppColors.surfaceContainerLow,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getIconColor(notif.type).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(notif.type),
                          color: _getIconColor(notif.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeStr,
                                  style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'queue':
      case 'ticket_called':
        return Icons.notifications_active_rounded;
      case 'alert':
        return Icons.campaign_rounded;
      case 'success':
      case 'ticket_completed':
        return Icons.check_circle_rounded;
      case 'skipped':
        return Icons.redo_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'queue':
      case 'ticket_called':
        return AppColors.primary;
      case 'alert':
        return Colors.deepOrange;
      case 'success':
      case 'ticket_completed':
        return AppColors.success;
      case 'skipped':
        return Colors.amber.shade800;
      default:
        return AppColors.primary;
    }
  }
}
