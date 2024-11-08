import 'dart:io';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/entry.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/src/rust/api/logger.dart';
import 'package:coriander_player/src/rust/frb_generated.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_fonts/system_fonts.dart';

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: const Size(507, 507),
    size: AppSettings.instance.windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

// Future<void> loadPrefFont() async {
//   final settings = AppSettings.instance;
//   if (settings.fontFamily != null) {
//     try {
//       final fontLoader = FontLoader(settings.fontFamily!);
//
//       fontLoader.addFont(
//         File(settings.fontPath!).readAsBytes().then((value) {
//           return ByteData.sublistView(value);
//         }),
//       );
//       await fontLoader.load();
//       ThemeProvider.instance.changeFontFamily(settings.fontFamily!);
//     } catch (err, trace) {
//       LOGGER.e(err, stackTrace: trace);
//     }
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  initRustLogger().listen((msg) {
    LOGGER.i("[rs]: $msg");
  });

  // For hot reload, `unregisterAll()` needs to be called.
  await HotkeysHelper.unregisterAll();
  HotkeysHelper.registerHotKeys();

  // await migrateAppData();

  final supportPath = (await getApplicationSupportDirectory()).path;
  if (File("$supportPath/settings.json").existsSync()) {
    await AppSettings.readFromJson();
    // await loadPrefFont();
    final settings = AppSettings.instance;
    if (settings.fontFamily != null) {
      SystemFonts().loadFont(settings.fontFamily!);
      ThemeProvider.instance.changeFontFamily(settings.fontFamily!);
    }
  }
  if (File("$supportPath/app_preference.json").existsSync()) {
    await AppPreference.read();
  }
  final welcome = !File("$supportPath/index.json").existsSync();
  await initWindow();

  runApp(Entry(welcome: welcome));
}
