// ignore_for_file: camel_case_types

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/horizontal_lyric_view.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.small:
            return const _TitleBar_Small();
          case ScreenType.medium:
            return const _TitleBar_Medium();
          case ScreenType.large:
            return const _TitleBar_Large();
        }
      },
    );
  }
}

class _TitleBar_Small extends StatelessWidget {
  const _TitleBar_Small();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const _OpenDrawerBtn(),
            const SizedBox(width: 8.0),
            const NavBackBtn(),
            Expanded(
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Coriander Player",
                    style: TextStyle(color: scheme.onSurface, fontSize: 16),
                  ),
                ),
              ),
            ),
            const WindowControlls(),
          ],
        ),
      ),
    );
  }
}

class _TitleBar_Medium extends StatelessWidget {
  const _TitleBar_Medium();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Center(child: NavBackBtn()),
        ),
        Expanded(
          child: DragToMoveArea(
            child: Row(
              children: [
                Text(
                  "Coriander Player",
                  style: TextStyle(color: scheme.onSurface, fontSize: 16),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: HorizontalLyricView(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const WindowControlls(),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

class _TitleBar_Large extends StatelessWidget {
  const _TitleBar_Large();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const NavBackBtn(),
          const SizedBox(width: 8.0),
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  SizedBox(
                    width: 248,
                    child: Row(
                      children: [
                        Image.asset("app_icon.ico", width: 24, height: 24),
                        const SizedBox(width: 8.0),
                        Text(
                          "Coriander Player",
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8.0, 16.0, 8.0),
                      child: HorizontalLyricView(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const WindowControlls(),
        ],
      ),
    );
  }
}

class _OpenDrawerBtn extends StatelessWidget {
  const _OpenDrawerBtn();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "打开导航栏",
      onPressed: Scaffold.of(context).openDrawer,
      icon: const Icon(Symbols.side_navigation),
    );
  }
}

class NavBackBtn extends StatelessWidget {
  const NavBackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "返回",
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      icon: const Icon(Symbols.navigate_before),
    );
  }
}

class WindowControlls extends StatefulWidget {
  const WindowControlls({super.key});

  @override
  State<WindowControlls> createState() => _WindowControllsState();
}

class _WindowControllsState extends State<WindowControlls> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    setState(() {});
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        FutureBuilder(
          future: windowManager.isFullScreen(),
          builder: (context, snapshot) {
            final isFullScreen = snapshot.data ?? true;
            return IconButton(
              tooltip: isFullScreen ? "退出全屏" : "全屏",
              onPressed: () async {
                await windowManager.hide();
                await windowManager.setFullScreen(!isFullScreen);
                await windowManager.show();
              },
              icon: Icon(
                isFullScreen ? Symbols.close_fullscreen : Symbols.open_in_full,
              ),
            );
          },
        ),
        IconButton(
          tooltip: "最小化",
          onPressed: windowManager.minimize,
          icon: const Icon(Symbols.remove),
        ),
        FutureBuilder(
          future: windowManager.isMaximized(),
          builder: (context, snapshot) {
            final isMaximized = snapshot.data ?? true;
            return IconButton(
              tooltip: isMaximized ? "还原" : "最大化",
              onPressed: isMaximized
                  ? windowManager.unmaximize
                  : windowManager.maximize,
              icon: Icon(
                isMaximized ? Symbols.fullscreen_exit : Symbols.fullscreen,
              ),
            );
          },
        ),
        IconButton(
          tooltip: "退出",
          onPressed: () async {
            // PlayService.instance.close();

            await savePlaylists();
            await saveLyricSources();
            await AppSettings.instance.saveSettings();
            await AppPreference.instance.save();

            await HotkeysHelper.unregisterAll();
            windowManager.close();
          },
          icon: const Icon(Symbols.close),
        ),
      ],
    );
  }
}
