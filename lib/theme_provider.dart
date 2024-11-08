import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
// import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: Color(AppSettings.instance.defaultTheme),
    brightness: Brightness.light,
  );

  ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: Color(AppSettings.instance.defaultTheme),
    brightness: Brightness.dark,
  );

  String? fontFamily = AppSettings.instance.fontFamily;

  ColorScheme get currScheme =>
      themeMode == ThemeMode.dark ? darkScheme : lightScheme;

  ThemeMode themeMode = AppSettings.instance.themeMode;

  static ThemeProvider? _instance;

  ThemeProvider._();

  static ThemeProvider get instance {
    _instance ??= ThemeProvider._();
    return _instance!;
  }

  void applyTheme({required Color seedColor}) {
    lightScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    darkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    notifyListeners();

    // PlayService.instance.desktopLyricService.canSendMessage.then((canSend) {
    //   if (!canSend) return;
    //
    //   PlayService.instance.desktopLyricService.sendThemeMessage(currScheme);
    // });
  }

  /// 应用从 image 生成的主题。只在 themeMode == this.themeMode 时通知改变。
  void applyThemeFromImage(ImageProvider image, ThemeMode themeMode) {
    final brightness = switch (themeMode) {
      ThemeMode.system => Brightness.light,
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };

    ColorScheme.fromImageProvider(
      provider: image,
      brightness: brightness,
    ).then(
      (value) {
        switch (brightness) {
          case Brightness.light:
            lightScheme = value;
            break;
          case Brightness.dark:
            darkScheme = value;
            break;
        }

        if (themeMode == this.themeMode) {
          notifyListeners();
          // PlayService.instance.desktopLyricService.canSendMessage
          //     .then((canSend) {
          //   if (!canSend) return;
          //
          //   PlayService.instance.desktopLyricService
          //       .sendThemeMessage(currScheme);
          // });
        }
      },
    );
  }

  void applyThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
    // PlayService.instance.desktopLyricService.canSendMessage.then((canSend) {
    //   if (!canSend) return;
    //
    //   PlayService.instance.desktopLyricService.sendThemeMessage(currScheme);
    //   PlayService.instance.desktopLyricService.sendThemeModeMessage(
    //     themeMode == ThemeMode.dark,
    //   );
    // });
  }

  void applyThemeFromAudio(Audio audio) {
    if (!AppSettings.instance.dynamicTheme) return;

    audio.cover.then((image) {
      if (image == null) return;

      applyThemeFromImage(image, themeMode);

      final second = switch (themeMode) {
        ThemeMode.system => ThemeMode.dark,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.light,
      };
      applyThemeFromImage(image, second);
    });
  }

  void changeFontFamily(String? fontFamily) {
    this.fontFamily = fontFamily;
    notifyListeners();
  }

  // ButtonStyle get primaryButtonStyle => ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.primary),
  //       foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
  //       fixedSize: const WidgetStatePropertyAll(Size.fromHeight(40.0)),
  //       overlayColor:
  //           WidgetStatePropertyAll(scheme.onPrimary.withOpacity(0.08)),
  //     );

  // ButtonStyle get secondaryButtonStyle => ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
  //       foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
  //       fixedSize: const WidgetStatePropertyAll(Size.fromHeight(40.0)),
  //       overlayColor: WidgetStatePropertyAll(
  //           scheme.onSecondaryContainer.withOpacity(0.08)),
  //     );

  // ButtonStyle get primaryIconButtonStyle => ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.primary),
  //       foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
  //       overlayColor: WidgetStatePropertyAll(
  //         scheme.onPrimary.withOpacity(0.08),
  //       ),
  //     );

  // ButtonStyle get secondaryIconButtonStyle => ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
  //       foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
  //       overlayColor: WidgetStatePropertyAll(
  //         scheme.onSecondaryContainer.withOpacity(0.08),
  //       ),
  //     );

  // ButtonStyle get menuItemStyle => ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
  //       foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
  //       padding: const WidgetStatePropertyAll(
  //         EdgeInsets.symmetric(horizontal: 16.0),
  //       ),
  //       overlayColor: WidgetStatePropertyAll(
  //         scheme.onSecondaryContainer.withOpacity(0.08),
  //       ),
  //     );

  // MenuStyle get menuStyleWithFixedSize => MenuStyle(
  //       backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
  //       surfaceTintColor: WidgetStatePropertyAll(scheme.secondaryContainer),
  //       shape: WidgetStatePropertyAll(RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20.0),
  //       )),
  //       fixedSize: const WidgetStatePropertyAll(Size.fromWidth(149.0)),
  //     );

  // MenuStyle get menuStyle => MenuStyle(
  //       shape: WidgetStatePropertyAll(
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       ),
  //       backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
  //       surfaceTintColor: WidgetStatePropertyAll(scheme.surfaceContainer),
  //     );

  // InputDecoration inputDecoration(String labelText) => InputDecoration(
  //       enabledBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: scheme.outline, width: 2),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: scheme.primary, width: 2),
  //       ),
  //       labelText: labelText,
  //       labelStyle: TextStyle(color: scheme.onSurfaceVariant),
  //       floatingLabelStyle: TextStyle(color: scheme.primary),
  //       focusColor: scheme.primary,
  //     );
}
