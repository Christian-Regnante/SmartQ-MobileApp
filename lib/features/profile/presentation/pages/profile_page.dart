import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedLanguage = 'English';

  void _onLogoutSubmitted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of SmartQ Rwanda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go(RouteConstants.login);
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final themeCubit = context.watch<ThemeCubit>();
    final isDarkMode = themeCubit.isDarkMode;

    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.fullName ?? 'User Account';
    final userEmail = user?.email ?? 'user@smartq.rw';
    final userRoleStr = user?.role.name ?? 'Client';
    final userPhone = user?.phoneNumber ?? '+250 788 123 456';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile & Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              NeumorphicCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 13, color: AppColors.outline),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userRoleStr.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              NeumorphicCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.phone_outlined, color: AppColors.primary),
                        title: Text(
                          'Phone Number',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(userPhone, style: const TextStyle(fontSize: 12)),
                        trailing: Icon(Icons.edit_outlined, size: 18, color: AppColors.outline),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.language_rounded, color: AppColors.primary),
                        title: Text(
                          'App Language',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12)),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.outline),
                          onSelected: (val) => setState(() => _selectedLanguage = val),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'English', child: Text('English 🇬🇧')),
                            PopupMenuItem(value: 'Kinyarwanda', child: Text('Kinyarwanda 🇷🇼')),
                            PopupMenuItem(value: 'Français', child: Text('Français 🇫🇷')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          isDarkMode
                              ? 'Aetheric Depth theme active'
                              : 'Switch to Aetheric Depth',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (val) => context.read<ThemeCubit>().setDarkMode(val),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.shield_outlined, color: AppColors.primary),
                        title: Text(
                          'Privacy & Terms',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'SmartQ Rwanda legal policies',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.outline,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              NeumorphicButton(
                text: 'Log Out of Account',
                type: NeumorphicButtonType.danger,
                onPressed: _onLogoutSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
