import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_strings.dart';
import '../providers/game_provider.dart';

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
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppStrings.version),
            trailing: const Text(AppStrings.versionNumber),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text(AppStrings.developer),
            trailing: const Text(AppStrings.nunuyaGames),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _launchPrivacyPolicy(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: const Text(
              AppStrings.resetData,
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.reset),
          ),
        ],
      ),
    );
  }
}
