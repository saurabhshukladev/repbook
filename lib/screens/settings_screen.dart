import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repbook/providers/settings_provider.dart';
import 'package:repbook/providers/workout_provider.dart';
import 'package:repbook/services/cache_service.dart';

/// Screen enabling users to configure GitHub authentication tokens and repository targets.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patController;
  late TextEditingController _ownerController;
  late TextEditingController _repoController;
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _patController = TextEditingController(text: settings.githubPat);
    _ownerController = TextEditingController(text: settings.githubOwner);
    _repoController = TextEditingController(text: settings.githubRepo);
    _pathController = TextEditingController(text: settings.githubPath);
  }

  @override
  void dispose() {
    _patController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = context.read<SettingsProvider>();
      await settings.saveSettings(
        pat: _patController.text,
        owner: _ownerController.text,
        repo: _repoController.text,
        path: _pathController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Settings saved successfully.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _clearCache() async {
    final cacheService = CacheService();
    await cacheService.clearCache();
    if (mounted) {
      // Reload schedule to reflect the empty cache state
      context.read<WorkoutProvider>().loadSchedule();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Local cache cleared.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Sync Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informational Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Configure a fine-grained Personal Access Token (PAT) with read access to a repository containing your schedule JSON (default: schedule.json).',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // GitHub PAT Input
                TextFormField(
                  controller: _patController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'GitHub PAT Token',
                    hintText: 'ghp_...',
                    helperText: 'Requires contents read permission.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'PAT Token is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Repository Owner Input
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: 'Repository Owner (Username/Org)',
                    hintText: 'torvalds',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Repository Owner is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Repository Name Input
                TextFormField(
                  controller: _repoController,
                  decoration: const InputDecoration(
                    labelText: 'Repository Name',
                    hintText: 'workout-schedule',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Repository Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Path inside repository
                TextFormField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'File Path in Repository',
                    hintText: 'schedule.json',
                  ),
                ),
                const SizedBox(height: 36),
                // Save Button
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                // Clear Cache Button
                OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Clear Local Cache'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
