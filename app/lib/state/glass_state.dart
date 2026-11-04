import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 玻璃透明度。1 = 作者的默认，越小人越透（最低 0.25，仍然可读）。
class GlassSettings {
  const GlassSettings({this.opacity = 1.0, this.loaded = false});

  final double opacity;
  final bool loaded;

  GlassSettings copyWith({double? opacity, bool? loaded}) =>
      GlassSettings(opacity: opacity ?? this.opacity, loaded: loaded ?? this.loaded);
}

class GlassController extends Notifier<GlassSettings> {
  static const key = 'appearance.glass_opacity';
  static const min = 0.25;
  static const max = 1.0;

  late Future<void> _loaded;

  @override
  GlassSettings build() {
    _loaded = _load();
    return const GlassSettings();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getDouble(key);
      state = GlassSettings(opacity: (stored ?? max).clamp(min, max), loaded: true);
    } catch (_) {
      state = state.copyWith(loaded: true);
    }
  }

  Future<void> setOpacity(double value) async {
    await _loaded;
    final next = value.clamp(min, max);
    state = GlassSettings(opacity: next, loaded: true);
    try {
      await (await SharedPreferences.getInstance()).setDouble(key, next);
    } catch (_) {
      // Kept for this run only.
    }
  }
}

final glassOpacityProvider = NotifierProvider<GlassController, GlassSettings>(GlassController.new);
