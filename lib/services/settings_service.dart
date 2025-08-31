
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'language_service.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal(){
    _startVersionPolling();
  }

  final String _base = AppConstants.apiBaseUrl;
  final LanguageService _lang = LanguageService();

  Map<String, dynamic> _settings = {};
  List<dynamic> _heroes = [];
  bool _loading = false;
  bool _loadedOnce = false;
  int _version = 0;
  Timer? _versionTimer;

  // Local app preferences (compatibility with SettingsScreen)
  final Map<String, dynamic> _localPrefs = {
    'darkMode': false,
    'notifications': true,
    'language': 'العربية',
  };

  Map<String, dynamic> get settings => _settings;
  List<dynamic> get heroes => _heroes;
  bool get isLoading => _loading;
  bool get hasLoaded => _loadedOnce;

  void _notifySafe() {
    // Always post notification after current frame to avoid setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loadedOnce && !force) return;
    _loading = true;
    // Do not notify immediately to avoid build-phase updates
    try {
      final settingsUri = Uri.parse('$_base/settings');
      final heroesUri = Uri.parse('$_base/hero_images');
      final results = await Future.wait([
        http.get(settingsUri),
        http.get(heroesUri),
      ]);
      final settingsRes = results[0];
      final heroesRes = results[1];
      if (settingsRes.statusCode >= 200 && settingsRes.statusCode < 300) {
        final data = jsonDecode(settingsRes.body);
        if (data is Map<String, dynamic>) {
          _settings = data;
        }
      }
      if (heroesRes.statusCode >= 200 && heroesRes.statusCode < 300) {
        final data = jsonDecode(heroesRes.body);
        if (data is List) {
          _heroes = data
              .where((e) => e is Map<String, dynamic>)
              .map((e) {
                final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
                final raw = (m['url'] ?? '') as String;
                if (raw.isNotEmpty && raw.startsWith('/')) {
                  // Normalize relative URL returned by backend uploads
                  m['url'] = '$_base$raw';
                }
                return m;
              })
              .where((e) => (e['is_active'] ?? true) == true)
              .toList()
            ..sort((a, b) => ((a['sort_order'] ?? 0) as int).compareTo((b['sort_order'] ?? 0) as int));
        }
      }
      _loadedOnce = true;
    } catch (_) {
      // keep previous cache on error
    } finally {
      _loading = false;
      _notifySafe();
    }
  }

  void _startVersionPolling() {
    _versionTimer?.cancel();
    _versionTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      try {
        final res = await http.get(Uri.parse('$_base/version'));
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final body = jsonDecode(res.body);
          final v = (body is Map && body['version'] is num) ? (body['version'] as num).toInt() : 0;
          if (v > _version) {
            _version = v;
            await load(force: true);
          }
        }
      } catch (_) {}
    });
  }

  String _langKey(String base) {
    final code = _lang.currentLanguage; // 'ar' | 'en' | 'tr'
    return '${base}_${code}';
    }

  String _localizedOrFallback(String base, {String defaultValue = ''}) {
    if (_settings.isEmpty) return defaultValue;
    final keyCurr = _langKey(base);
    final keyAr = '${base}_ar';
    final keyEn = '${base}_en';
    final keyTr = '${base}_tr';
    return (_settings[keyCurr] as String?) ??
        (_settings[keyAr] as String?) ??
        (_settings[keyEn] as String?) ??
        (_settings[keyTr] as String?) ??
        defaultValue;
  }

  String get appTitle => _localizedOrFallback('app_title', defaultValue: _localizedOrFallback('menu_title', defaultValue: 'The Kitchen'));
  String get heroText => _localizedOrFallback('hero_text', defaultValue: '');
  String get subtitle => _localizedOrFallback('subtitle', defaultValue: LanguageService().translate('restaurants_london'));
  String get viewMenuLabel => _localizedOrFallback('view_menu_label', defaultValue: LanguageService().translate('view_menu'));
  String get orderNowLabel => _localizedOrFallback('order_now_label', defaultValue: LanguageService().translate('order_now'));
  String get menuTitle => _localizedOrFallback('menu_title', defaultValue: 'Menu');

  // Local preferences compatibility layer for SettingsScreen
  Map<String, dynamic> getSettings() => Map<String, dynamic>.from(_localPrefs);
  Future<void> saveSetting(String key, dynamic value) async {
    _localPrefs[key] = value;
    if (key == 'language') {
      // Update language in LanguageService and reload settings from backend to reflect language immediately
      final langCode = value == 'English' ? 'en' : value == 'Türkçe' ? 'tr' : 'ar';
      _lang.changeLanguage(langCode);
      await load(force: true);
    }
    _notifySafe();
  }
}
