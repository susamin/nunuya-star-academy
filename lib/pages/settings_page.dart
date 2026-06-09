import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _privacyPolicyUrl =
      'https://susamin.github.io/nunuya-star-academy/privacy_policy.html';

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法開啟隱私政策頁面')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgGradient,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                _sectionLabel('遊戲資訊'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _GlassTile(
                        icon: Icons.info_outline,
                        label: AppStrings.version,
                        trailing: Text(
                          AppStrings.versionNumber,
                          style: const TextStyle(color: AppColors.textOnDarkMuted),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.glassBorder),
                      _GlassTile(
                        icon: Icons.person_outline,
                        label: AppStrings.developer,
                        trailing: Text(
                          AppStrings.nunuyaGames,
                          style: const TextStyle(color: AppColors.textOnDarkMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel('法律'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _GlassTile(
                    icon: Icons.privacy_tip_outlined,
                    label: AppStrings.privacyPolicy,
                    trailing: const Icon(
                      Icons.open_in_new,
                      size: 15,
                      color: AppColors.lavender,
                    ),
                    onTap: () => _launchPrivacyPolicy(context),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel('資料'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _GlassTile(
                    icon: Icons.refresh,
                    label: AppStrings.resetData,
                    iconColor: AppColors.roseRed,
                    labelColor: AppColors.roseRed,
                    onTap: () => _confirmReset(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textOnDarkFaint,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmReset),
        content: const Text(AppStrings.confirmResetMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameProvider.notifier).resetData();
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.roseRed),
            child: const Text(AppStrings.reset),
          ),
        ],
      ),
    );
  }
}

class _GlassTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color labelColor;

  const _GlassTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.lavender,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
