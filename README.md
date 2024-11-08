# Coriander Player Linux：一款使用 Material You 配色的本地音乐播放器。

![音乐页](软件截图/音乐页.png)

正在学习开发Flutter应用，不保证所有bug都能修复（逃

~~该播放器拥有桌面歌词组件。这个桌面歌词组件也可以给别的音乐播放器使用。请见 [desktop_lyric](https://github.com/Ferry-200/desktop_lyric.git)~~  

Linux端暂无法实现透明背景的桌面歌词，故移除该功能

## 已知问题  

* Linux端设置页面中选择字体，字体列表为空（`system_fonts`库只会扫描`/usr/share/fonts/`和`$HOME/.local/share/fonts/`中的字体而没有扫描子目录）

## TODO  

- [ ] 添加mpris支持  

- [ ] 等学习Rust后尝试实现透明背景的桌面歌词（参考[waylyrics](https://github.com/waylyrics/waylyrics)）

- [x] 重新使用libbass解码

## 安装

下载 [Release](https://github.com/Sh12uku/coriander_player_linux/releases/latest) 里文件安装

## 支持播放的音乐格式

~~由于兼容性问题更换 bass lib 为 Flutter库 audioplayers, 支持格式见[audio types](https://gstreamer.freedesktop.org/documentation/plugin-development/advanced/media-types.html?gi-language=c#table-of-audio-types)~~

~~我是笨比，以为ffi生成的代码也是跨平台的~~

见源仓库，具体支持情况未测试。

## 支持下列音乐格式的内嵌歌词

- aac
- aiff
- flac
- m4a
- mp3
- ogg
- opus
- wav（标签必须用 UTF-8 编码）

其他格式的只支持同目录的 lrc 文件或者是网络歌词

## 选择默认歌词

默认情况下，软件会先读取本地歌词。如果没有，则匹配在线歌词。
你可以在正在播放界面的歌词切换按钮展开的菜单中进入选择默认歌词的页面。

![音乐页](软件截图/选择默认歌词.png)
在这个界面中，你可以在本地歌词（如果有）和几个匹配程度高的在线歌词中选择一个作为默认歌词。之后再播放这首音乐时，软件会加载你指定的歌词。

## 提供建议、提交 Bug 或者提 PR

我正处于学习和适应 Github 工作流的阶段，所以目前不设置太多的要求。你只需要注意以下几点： 

1. 如果要提交 Bug，请创建一个新的 issue。尽可能说明复现步骤并提供截图。
2. 如果你提交 PR，由于我正在学习相关知识，可能会在处理 PR 时和你沟通如何操作分支之类的问题。

## 编译

1. 开发 flutter 需要的环境以及flutter_rust_bridge（rust环境，Corrosion）
2. 直接编译 Coriander Player（本仓库） 软件本体  

## 歌词特性解释

1. lrc歌词的间奏识别   
   在一些lrc歌词中，会使用 **只有时间标签而内容为空** 的一行来表示上一行的结束。如：
   
   ```
   [02:32.57]光は やさしく抱きしめた
   [02:32.57]那天没能放声大哭的我
   [02:39.94]
   [02:55.18]照らされた世界 咲き誇る大切な人
   [02:55.18]光芒普照整个世界 珍重之人绽放于心
   ```
   
   如果这一行（第三行）的时间戳和下一行的时间戳之间大于5s，就把这两行之间的时间作为间奏时长  
   **所以，不是所有lrc歌词在间奏时都能显示间奏动画。**
2. krc、qrc逐字歌词的间奏识别  
   逐字歌词都会给出每一行的开始时间和持续时间，所以识别间奏会简单得多。如
   
   ```
   [5905,5466]<0,217,0>世<217,383,0>界<600,495,0>は<1095,272,0>と<1367,328,0>て<1695,343,0>も<2038,616,0>綺<2654,752,0>麗<3406,276,0>だ<3682,276,0>っ<3958,504,0>た<4462,1004,0>な
   [23037,5254]<0,255,0>書<255,280,0>架<535,312,0>の<847,592,0>隙<1439,312,0>間<1751,223,0>に<1974,160,0>住<2134,144,0>ま<2278,352,0>う<2630,640,0>一<3270,640,0>輪<3910,190,0>の<4100,680,0>花<4780,474,0>は
   ```
   
   第一行的开始时间是 5905ms，持续 5466ms；第二行则是 23037ms和 5254ms。可见 5905 + 5466 = 11371，与 23037相差超过 5000ms，所以这两行时间可以插入表示间奏的空白行

## 感谢

- [源项目](https://github.com/Ferry-200/coriander_player)：实现应用全部功能
- [music_api](https://github.com/yhsj0919/music_api.git)：实现歌曲的匹配和歌词的获取
- [Lofty](https://crates.io/crates/lofty)：歌曲标签获取
- [BASS](https://www.un4seen.com/bass.html)：播放乐曲
- [flutter_rust_bridge](https://pub.dev/packages/flutter_rust_bridge)
