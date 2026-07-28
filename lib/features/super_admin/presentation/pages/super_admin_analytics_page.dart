import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';

class SuperAdminAnalyticsPage extends StatelessWidget {
  const SuperAdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('National Queue Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rwanda National Infrastructure',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Real-time queue load monitoring across all provinces',
                style: TextStyle(fontSize: 13, color: AppColors.outline),
              ),
              const SizedBox(height: 20),

              // Stat Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: const [
                  StatCard(
                    label: 'Total Customers Today',
                    value: '14,820',
                    icon: Icons.groups_rounded,
                    valueColor: AppColors.primary,
                  ),
                  StatCard(
                    label: 'Active Counters',
                    value: '184',
                    icon: Icons.meeting_room_outlined,
                    valueColor: AppColors.success,
                  ),
                  StatCard(
                    label: 'Avg National Wait',
                    value: '9.8 min',
                    icon: Icons.timer_outlined,
                    valueColor: Colors.deepOrange,
                  ),
                  StatCard(
                    label: 'Platform SLA',
                    value: '99.99%',
                    icon: Icons.verified_rounded,
                    valueColor: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sector Share Breakdown Card
              NeumorphicCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Queue Distribution by Sector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectorRow('Healthcare (Hospitals/Clinics)', '45%', AppColors.primary, 0.45),
                    const SizedBox(height: 12),
                    _buildSectorRow('Banking & Financial', '32%', AppColors.success, 0.32),
                    const SizedBox(height: 12),
                    _buildSectorRow('Government e-Services', '23%', Colors.deepOrange, 0.23),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorRow(String title, String percentage, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(percentage, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.outlineVariant,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
