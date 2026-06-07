import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
import '../providers/game_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

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
            onTap: () {
              // TODO: launch privacy policy URL before App Store submission
            },
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
