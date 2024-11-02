import 'dart:async';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/play_service/play_service.dart';
// import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:coriander_player/src/rust/api/smtc_flutter.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/foundation.dart';

enum PlayMode {
  /// 顺序播放到播放列表结尾
  forward,

  /// 循环整个播放列表
  loop,

  /// 循环播放单曲
  singleLoop;

  static PlayMode? fromString(String playMode) {
    for (var value in PlayMode.values) {
      if (value.name == playMode) return value;
    }
    return null;
  }
}

/// 只通知 now playing 变更
class PlaybackService extends ChangeNotifier {
  final PlayService playService;

  late StreamSubscription _playerStateStreamSub;
  late StreamSubscription<Duration> _durationStreamSub;
  late StreamSubscription<Duration> _positionStreamSub;

  Duration _duration = Duration(seconds: 1);
  Duration _position = Duration.zero;

  // late StreamSubscription _smtcEventStreamSub;

  PlaybackService(this.playService) {
    _playerStateStreamSub = playerStateStream.listen((event) {
      if (event == PlayerState.completed) {
        _autoNextAudio();
      }
    });
    _durationStreamSub = durationStream.listen((event) {
      _duration = event;
    });
    _positionStreamSub = positionStream.listen((event) {
      _position = event;
    });

    // _smtcEventStreamSub = _smtc.subscribeToControlEvents().listen((event) {
    //   switch (event) {
    //     case SMTCControlEvent.play:
    //       start();
    //       break;
    //     case SMTCControlEvent.pause:
    //       pause();
    //       break;
    //     case SMTCControlEvent.previous:
    //       lastAudio();
    //       break;
    //     case SMTCControlEvent.next:
    //       nextAudio();
    //       break;
    //     case SMTCControlEvent.unknown:
    //   }
    // });
  }

  // final _player = BassPlayer();
  final _player = AudioPlayer();
  // final _smtc = SmtcFlutter();
  final _pref = AppPreference.instance.playbackPref;

  // late final _wasapiExclusive = ValueNotifier(_player.wasapiExclusive);
  // ValueNotifier<bool> get wasapiExclusive => _wasapiExclusive;
  //
  // /// 独占模式
  // void useExclusiveMode(bool exclusive) {
  //   if (_player.useExclusiveMode(exclusive)) {
  //     _wasapiExclusive.value = exclusive;
  //   }
  // }

  Audio? nowPlaying;

  int? _playlistIndex;
  int get playlistIndex => _playlistIndex ?? 0;

  final ValueNotifier<List<Audio>> playlist = ValueNotifier([]);
  List<Audio> _playlistBackup = [];

  late final _playMode = ValueNotifier(_pref.playMode);
  ValueNotifier<PlayMode> get playMode => _playMode;

  void setPlayMode(PlayMode playMode) {
    this.playMode.value = playMode;
    _pref.playMode = playMode;
  }

  late final _shuffle = ValueNotifier(false);
  ValueNotifier<bool> get shuffle => _shuffle;

  Duration get length => _duration;

  Duration get position => _position;

  PlayerState get playerState => _player.state;

  double get volumeDsp => _player.volume;

  /// 修改解码时的音量（不影响 Windows 系统音量）
  void setVolumeDsp(double volume) {
    _player.setVolume(volume);
    _pref.volumeDsp = volume;
  }

  Stream<Duration> get positionStream => _player.onPositionChanged.asBroadcastStream();

  Stream<Duration> get durationStream => _player.onDurationChanged;

  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  /// 1. 更新 [_playlistIndex] 为 [audioIndex]
  /// 2. 更新 [nowPlaying] 为 playlist[_nowPlayingIndex]
  /// 3. _bassPlayer.setSource
  /// 4. 设置解码音量
  /// 4. 获取歌词 **将 [_nextLyricLine] 置为0**
  /// 5. 播放
  /// 6. 通知并更新主题色
  void _loadAndPlay(int audioIndex, List<Audio> playlist) {
    try {
      _playlistIndex = audioIndex;
      nowPlaying = playlist[audioIndex];
      _player.setSource(DeviceFileSource(nowPlaying!.path));
      setVolumeDsp(AppPreference.instance.playbackPref.volumeDsp);

      playService.lyricService.updateLyric();

      _player.resume();
      notifyListeners();
      ThemeProvider.instance.applyThemeFromAudio(nowPlaying!);

      // _smtc.updateState(state: SMTCState.playing);
      // _smtc.updateDisplay(
      //   title: nowPlaying!.title,
      //   artist: nowPlaying!.artist,
      //   album: nowPlaying!.album,
      //   path: nowPlaying!.path,
      // );

      // playService.desktopLyricService.canSendMessage.then((canSend) {
      //   if (!canSend) return;

        // playService.desktopLyricService
        //     .sendPlayerStateMessage(playerState == PlayerState.playing);
        // playService.desktopLyricService.sendNowPlayingMessage(nowPlaying!);
      // });
    } catch (err) {
      LOGGER.e("[load and play] $err");
      showTextOnSnackBar(err.toString());
    }
  }

  /// 播放当前播放列表的第几项，只能用在播放列表界面
  void playIndexOfPlaylist(int audioIndex) {
    _loadAndPlay(audioIndex, playlist.value);
  }

  /// 播放playlist[audioIndex]并设置播放列表为playlist
  void play(int audioIndex, List<Audio> playlist) {
    if (shuffle.value) {
      this.playlist.value = List.from(playlist);
      final willPlay = this.playlist.value.removeAt(audioIndex);
      this.playlist.value.shuffle();
      this.playlist.value.insert(0, willPlay);
      _playlistBackup = List.from(playlist);
      _loadAndPlay(0, this.playlist.value);
    } else {
      _loadAndPlay(audioIndex, playlist);
      this.playlist.value = List.from(playlist);
      _playlistBackup = List.from(playlist);
    }
  }

  void shuffleAndPlay(List<Audio> audios) {
    playlist.value = List.from(audios);
    playlist.value.shuffle();
    _playlistBackup = List.from(audios);

    shuffle.value = true;

    _loadAndPlay(0, playlist.value);
  }

  /// 下一首播放
  void addToNext(Audio audio) {
    if (_playlistIndex != null) {
      playlist.value.insert(_playlistIndex! + 1, audio);
      _playlistBackup = List.from(playlist.value);
    }
  }

  void useShuffle(bool flag) {
    if (nowPlaying == null) return;
    if (flag == shuffle.value) return;

    if (flag) {
      playlist.value.shuffle();
      playlist.value.remove(nowPlaying!);
      playlist.value.insert(0, nowPlaying!);
      _playlistIndex = 0;
      shuffle.value = true;
    } else {
      playlist.value = List.from(_playlistBackup);
      _playlistIndex = playlist.value.indexOf(nowPlaying!);
      shuffle.value = false;
    }
  }

  void _nextAudio_forward() {
    if (_playlistIndex == null) return;

    if (_playlistIndex! < playlist.value.length - 1) {
      _loadAndPlay(_playlistIndex! + 1, playlist.value);
    }
  }

  void _nextAudio_loop() {
    if (_playlistIndex == null) return;

    int newIndex = _playlistIndex! + 1;
    if (newIndex >= playlist.value.length) {
      newIndex = 0;
    }

    _loadAndPlay(newIndex, playlist.value);
  }

  void _nextAudio_singleLoop() {
    if (_playlistIndex == null) return;

    _loadAndPlay(_playlistIndex!, playlist.value);
  }

  void _autoNextAudio() {
    switch (playMode.value) {
      case PlayMode.forward:
        _nextAudio_forward();
        break;
      case PlayMode.loop:
        _nextAudio_loop();
        break;
      case PlayMode.singleLoop:
        _nextAudio_singleLoop();
        break;
    }
  }

  /// 手动下一曲时默认循环播放列表
  void nextAudio() => _nextAudio_loop();

  /// 手动上一曲时默认循环播放列表
  void lastAudio() {
    if (_playlistIndex == null) return;

    int newIndex = _playlistIndex! - 1;
    if (newIndex < 0) {
      newIndex = playlist.value.length - 1;
    }

    _loadAndPlay(newIndex, playlist.value);
  }

  /// 暂停
  void pause() {
    try {
      _player.pause();
      // _smtc.updateState(state: SMTCState.paused);
      // playService.desktopLyricService.canSendMessage.then((canSend) {
      //   if (!canSend) return;
      //
      //   playService.desktopLyricService.sendPlayerStateMessage(false);
      // });
    } catch (err) {
      LOGGER.e("[pause] $err");
      showTextOnSnackBar(err.toString());
    }
  }

  /// 恢复播放
  void start() {
    try {
      _player.resume();
      // _smtc.updateState(state: SMTCState.playing);
      // playService.desktopLyricService.canSendMessage.then((canSend) {
      //   if (!canSend) return;
      //
      //   playService.desktopLyricService.sendPlayerStateMessage(true);
      // });
    } catch (err) {
      LOGGER.e("[start]: $err");
      showTextOnSnackBar(err.toString());
    }
  }

  /// 再次播放。在顺序播放完最后一曲时再次按播放时使用。
  /// 与 [start] 的差别在于它会通知重绘组件
  void playAgain() => _nextAudio_singleLoop();

  void seek(double position) {
    _player.seek(Duration(milliseconds: (position * 1000).toInt()));
    playService.lyricService.findCurrLyricLine();
  }

  void close() {
    _playerStateStreamSub.cancel();
    // _smtcEventStreamSub.cancel();
    // _player.free();
    _player.dispose();
    // _smtc.close();
  }
}
