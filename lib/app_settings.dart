import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

class AppSettings {
  static final github = GitHub();
  static const String version = "1.1.0";

  /// 主题模式：亮 / 暗
  /// 默认跟随系统
  ThemeMode themeMode = ThemeMode.system;

  /// 启动时 / 封面主题色不适合当主题时的主题
  /// 暂时调整为固定值
  // int defaultTheme = getWindowsTheme();
  int defaultTheme = const Color.fromARGB(0, 0, 0, 0).value;

  /// 跟随歌曲封面的动态主题
  bool dynamicTheme = true;

  /// 跟随系统主题色
  bool useSystemTheme = true;

  /// 跟随系统主题模式
  bool useSystemThemeMode = true;

  List artistSeparator = ["/", "、"];

  /// 歌词来源：true，本地优先；false，在线优先
  bool localLyricFirst = true;
  Size windowSize = const Size(1280, 756);

  String? fontFamily;
  // String? fontPath;

  late String artistSplitPattern = artistSeparator.join("|");

  static final AppSettings _instance = AppSettings._();

  static AppSettings get instance => _instance;

  /// 获取系统主题模式
  /*static ThemeMode getWindowsThemeMode() {
    final systemTheme = SystemTheme.getSystemTheme();

    final isDarkMode = (((5 * systemTheme.fore.$3) +
        (2 * systemTheme.fore.$2) +
        systemTheme.fore.$4) >
        (8 * 128));
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }*/

  /// 获取Windows主题色
  /*static int getWindowsTheme() {
    final systemTheme = SystemTheme.getSystemTheme();
    return Color.fromARGB(
      systemTheme.accent.$1,
      systemTheme.accent.$2,
      systemTheme.accent.$3,
      systemTheme.accent.$4,
    ).value;
  }*/

  AppSettings._();

  static Future<void> _readFromJson_old(Map settingsMap) async {
    final ust = settingsMap["UseSystemTheme"];
    if (ust != null) {
      _instance.useSystemTheme = ust == 1 ? true : false;
    }

    final ustm = settingsMap["UseSystemThemeMode"];
    if (ustm != null) {
      _instance.useSystemThemeMode = ustm == 1 ? true : false;
    }

    if (!_instance.useSystemTheme) {
      _instance.defaultTheme = settingsMap["DefaultTheme"];
    }
    if (!_instance.useSystemThemeMode) {
      _instance.themeMode =
      settingsMap["ThemeMode"] == 0 ? ThemeMode.light : ThemeMode.dark;
    }

    _instance.dynamicTheme = settingsMap["DynamicTheme"] == 1 ? true : false;
    _instance.artistSeparator = settingsMap["ArtistSeparator"];
    _instance.artistSplitPattern = _instance.artistSeparator.join("|");

    final llf = settingsMap["LocalLyricFirst"];
    if (llf != null) {
      _instance.localLyricFirst = llf == 1 ? true : false;
    }

    final sizeStr = settingsMap["WindowSize"];
    if (sizeStr != null) {
      final sizeStrs = (sizeStr as String).split(",");
      _instance.windowSize = Size(double.tryParse(sizeStrs[0]) ?? 1280,
          double.tryParse(sizeStrs[1]) ?? 756);
    }
  }

  static Future<void> readFromJson() async {
    final supportPath = (await getApplicationSupportDirectory()).path;
    final settingsPath = "$supportPath/settings.json";

    final settingsStr = File(settingsPath).readAsStringSync();
    Map settingsMap = json.decode(settingsStr);

    if (settingsMap["Version"] == null) {
      return _readFromJson_old(settingsMap);
    }

    final ust = settingsMap["UseSystemTheme"];
    if (ust != null) {
      _instance.useSystemTheme = ust;
    }

    final ustm = settingsMap["UseSystemThemeMode"];
    if (ustm != null) {
      _instance.useSystemThemeMode = ustm;
    }

    if (!_instance.useSystemTheme) {
      _instance.defaultTheme = settingsMap["DefaultTheme"];
    }
    if (!_instance.useSystemThemeMode) {
      _instance.themeMode = (settingsMap["ThemeMode"] ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    final dt = settingsMap["DynamicTheme"];
    if (dt != null) {
      _instance.dynamicTheme = dt;
    }

    final _as = settingsMap["ArtistSeparator"];
    if (_as != null) {
      _instance.artistSeparator = _as;
      _instance.artistSplitPattern = _instance.artistSeparator.join("|");
    }


    final llf = settingsMap["LocalLyricFirst"];
    if (llf != null) {
      _instance.localLyricFirst = llf;
    }

    final sizeStr = settingsMap["WindowSize"];
    if (sizeStr != null) {
      final sizeStrs = (sizeStr as String).split(",");
      _instance.windowSize = Size(double.tryParse(sizeStrs[0]) ?? 1280,
          double.tryParse(sizeStrs[1]) ?? 756);
    }

    final ff = settingsMap["FontFamily"];
    // final fp = settingsMap["FontPath"];
    if (ff != null) {
      _instance.fontFamily = ff;
      // _instance.fontPath = fp;
    }
  }

  Future<void> saveSettings() async {
    final currSize = await windowManager.getSize();
    final settingsMap = {
      "Version": version,
      "ThemeMode": themeMode == ThemeMode.dark,
      "DynamicTheme": dynamicTheme,
      "UseSystemTheme": useSystemTheme,
      "UseSystemThemeMode": useSystemThemeMode,
      "DefaultTheme": defaultTheme,
      "ArtistSeparator": artistSeparator,
      "LocalLyricFirst": localLyricFirst,
      "WindowSize":
      "${currSize.width.toStringAsFixed(1)},${currSize.height.toStringAsFixed(1)}",
      "FontFamily": fontFamily,
      // "FontPath": fontPath,
    };

    final settingsStr = json.encode(settingsMap);
    final supportPath = (await getApplicationSupportDirectory()).path;
    final settingsPath = "$supportPath/settings.json";
    File(settingsPath).writeAsStringSync(settingsStr);
  }
}
