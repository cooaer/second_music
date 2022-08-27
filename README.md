# second_music
一个聚合音乐客户端。

## 支持平台
- [x] [网易云音乐](https://music.163.com)
- [x] [QQ音乐](https://y.qq.com)
- [x] [~~虾米音乐~~](https://www.xiami.com)（已关闭）
- [x] [哔哩哔哩音乐区](https://www.bilibili.com/v/music/)
- [x] [咪咕音乐](https://music.migu.cn)

## 已完成功能
- [x] 热门推荐
- [x] 搜索单曲、歌单、歌手、专辑
- [x] 展示歌单、专辑、歌手等详情
- [x] 收藏管理
- [x] 在线播放歌曲
- [x] 后台播放

## 待完成功能
- [ ] 下载歌曲
- [ ] 播放历史
- [ ] 歌词

## 一些页面预览
| ![my_playlist](https://github.com/cooaer/second_music/blob/master/screenshots/my_playlist.jpg?raw=true) | ![hot_playlist](https://github.com/cooaer/second_music/blob/master/screenshots/hot_playlist.jpg?raw=true) | ![playlist](https://github.com/cooaer/second_music/blob/master/screenshots/playlist.jpg?raw=true) |
| :------: | :------: | :------: |
| ![play](https://github.com/cooaer/second_music/blob/master/screenshots/play.jpg?raw=true) | ![search_history](https://github.com/cooaer/second_music/blob/master/screenshots/search_history.jpg?raw=true) | ![search_result](https://github.com/cooaer/second_music/blob/master/screenshots/search_result.jpg?raw=true) |
| ![play](https://github.com/cooaer/second_music/blob/master/screenshots/singer_songs.jpg?raw=true) | ![search_history](https://github.com/cooaer/second_music/blob/master/screenshots/singer_albums.jpg?raw=true) | |


## 编译
暂时只能编译为 APK 在 Android 系统上运行。

若要在 iOS 上运行，需要解决两个问题。第一，在 Dart 侧实现网易云音乐 API 加密的逻辑，或者在 iOS 侧实现 NeteaseMusicCipher 的加密逻辑；第二，解决在 iOS 系统上 ResolvingAudioSource 在加入后 PlayList 后会立即解析 soundUrl 的问题；

## 感谢
第二音乐项目依赖众多其他开源项目。感谢开源社区的开发者。

#### 特别感谢
* [listen1_chrome_extension](https://github.com/listen1/listen1_chrome_extension)：one for all free music in china (chrome extension, also works for firefox)
* [just_audio](https://github.com/ryanheise/just_audio)：just_audio is a feature-rich audio player for Android, iOS, macOS, web, Linux and Windows.
* [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi)：网易云音乐 Node.js API service
* [QQMusicApi](https://github.com/jsososo/QQMusicApi)：基于 Express + Axios 的 QQ音乐接口 nodejs 版
* [MiguMusicApi](https://github.com/jsososo/MiguMusicApi)：咪咕音乐 nodejs api
* [bilibili-api](https://github.com/MoyuScript/bilibili-api)：哔哩哔哩的API调用模块

## 开源协议
MIT

