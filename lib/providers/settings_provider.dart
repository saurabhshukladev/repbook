import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages GitHub connection credentials stored in local persistent storage.
class SettingsProvider extends ChangeNotifier {
  String _githubPat = '';
  String get githubPat => _githubPat;

  String _githubOwner = '';
  String get githubOwner => _githubOwner;

  String _githubRepo = '';
  String get githubRepo => _githubRepo;

  String _githubPath = '';
  String get githubPath => _githubPath;

  bool get isConfigured =>
      _githubPat.isNotEmpty &&
      _githubOwner.isNotEmpty &&
      _githubRepo.isNotEmpty &&
      _githubPath.isNotEmpty;

  /// Loads configuration credentials from local persistent SharedPreferences.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _githubPat = prefs.getString('github_pat') ?? '';
    _githubOwner = prefs.getString('github_owner') ?? '';
    _githubRepo = prefs.getString('github_repo') ?? '';
    _githubPath = prefs.getString('github_path') ?? 'schedule.json';
    notifyListeners();
  }

  /// Saves updated configurations into local SharedPreferences.
  Future<void> saveSettings({
    required String pat,
    required String owner,
    required String repo,
    required String path,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _githubPat = pat.trim();
    _githubOwner = owner.trim();
    _githubRepo = repo.trim();
    _githubPath = path.trim().isEmpty ? 'schedule.json' : path.trim();

    await prefs.setString('github_pat', _githubPat);
    await prefs.setString('github_owner', _githubOwner);
    await prefs.setString('github_repo', _githubRepo);
    await prefs.setString('github_path', _githubPath);
    notifyListeners();
  }

  /// Removes saved settings and resets local variables.
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_pat');
    await prefs.remove('github_owner');
    await prefs.remove('github_repo');
    await prefs.remove('github_path');

    _githubPat = '';
    _githubOwner = '';
    _githubRepo = '';
    _githubPath = '';
    notifyListeners();
  }
}
