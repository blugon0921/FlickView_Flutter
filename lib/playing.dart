import 'dart:async';
import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flick_view/FFmpeg.dart';
import 'package:flick_view/FFprobe.dart';
import 'package:flick_view/main.dart';
import 'package:flick_view/widget/SideBarItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:window_size/window_size.dart';


class PlayingScreen extends StatefulWidget {
  final File file;
  const PlayingScreen({
    super.key,
    required this.file,
  });

  @override
  State<PlayingScreen> createState() => PlayingPage();
}

class PlayingPage extends State<PlayingScreen> {
  final player = Player();
  late final controller = VideoController(player);
  late var videoState = PlayerState();

  SideMenuController sideBar = SideMenuController();
  final List<SideBarItem> sideItems = [];
  // final List<SideBarItem> sideItems = [];
  final thumbnailsFolder = "${appData.path}\\thumbnails";

  var videoDuration = "";
  var videoSize = Size(0, 0);

  // var thumbnailPath = "assets/images/unloadedThumbnail.png";
  // var thumbnailPath = "C:\\CodingFile\\Flutter\\FlickView\\assets\\images\\unloadedThumbnail.png";
  var thumbnailPath = "";

  @override
  void initState() {
    Directory(thumbnailsFolder).createSync(recursive: true);
    player.open(Media(widget.file.path));
    setWindowTitle("Flick View | ${basename(widget.file.path)}");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _addSideItems();
    });
    Timer.periodic(Duration(milliseconds: 1), (timer) { //Update State
      if(ffmpegFolder.ffmpeg().existsSync() && ffmpegFolder.ffprobe().existsSync()) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          var ffmpeg = FFmpeg(ffmpegFolder.ffmpeg().path);
          var ffprobe = FFprobe(ffmpegFolder.ffprobe().path);
          //Info
          var info = await ffprobe.info(widget.file.path);
          if(info == null) {
            videoDuration = "0";
            videoSize = Size(0, 0);
          } else {
            videoDuration = durationToTime(Duration(milliseconds: (info.duration*1000).toInt()));
            videoSize = Size(info.size.width, info.size.height);
          }
          setState(() { });

          //Thumbnail
          var thumbnailFile = File("$thumbnailsFolder\\${basename(widget.file.path)}.png");
          if(!thumbnailFile.existsSync()) {
            var thumbnailFile = await saveThumbnail(widget.file.path, ffmpeg, ffprobe);
          }
          if(thumbnailFile.existsSync()) {
            thumbnailPath = thumbnailFile.path;
          }
          setState(() { });
        });
        timer.cancel();
      } else if(videoDuration == "") {
        videoDuration = "FFMPEG 다운로드중...";
        setState(() { });
      }
    });
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    super.initState();
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if(event is KeyDownEvent) {
      if(key == "Escape") {
        runApp(MyScreen());
      }
    }
    return false;
  }

  Future<File> saveThumbnail(String videoPath, FFmpeg ffmpeg, FFprobe ffprobe) async {
    var info = await ffprobe.info(videoPath);
    if(info == null) {
      return File("$thumbnailsFolder\\${basename(videoPath)}.png");
    }
    var width = info.size.width;
    var height = info.size.height;
    var saveTime = info.duration/2;
    var ratio = width/height;
    height = 300;
    width = (height*ratio).floorToDouble();
    return await ffmpeg.saveScreenshot(videoPath, saveTime, "$thumbnailsFolder\\${basename(videoPath)}.png",
      scale: Size(width, height)
    );
  }

  _addSideItems() async {
    var items = (await dirContents(widget.file.parent)).whereType<File>();
    for (var value in items) {
      final mimeType = lookupMimeType(value.path);
      if(mimeType == null) continue;
      if(!mimeType.startsWith("video")) continue;
      sideItems.add(SideBarItem(
        // thumbnailPath: basename(value.path),
        // thumbnailPath: "assets/test/thumbnail.png",
        videoPath: value.path,
      ));
      setState(() {});
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen (
            (file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files)
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    var fullSize = MediaQuery.of(context).size;
    var sideBarWidth = (fullSize.width*25/100-3).floorToDouble();

    var thumbnail = Image.asset("assets/images/unloadedThumbnail.png",
      width: sideBarWidth,
    );
    if(thumbnailPath != "") {
      thumbnail = Image.file(File(thumbnailPath),
        width: sideBarWidth,
      );
    }

    return MaterialApp(
      home: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Video(
            controller: controller,
            width: fullSize.width-(sideBarWidth+3), // 80%
            height: fullSize.height,
            controls: AdaptiveVideoControls,
            fill: Color(0xff1E1F22),
          ),
          Container(
            color: Color(0xFF525763),
            width: 3,
            height: fullSize.height,
          ),
          Container(
            color: Color(0xFF27292E),
            height: fullSize.height,
            child: SingleChildScrollView (
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Image.asset(thumbnail,
                  thumbnail,
                  Container(
                    width: sideBarWidth,
                    height: sideBarWidth*0.11609498680738786279683377308707,
                    decoration: BoxDecoration(
                      color: Color(0xff27292E),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 0)
                        )
                      ],
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF525763),
                          width: 3
                        )
                      )
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: sideBarWidth/2-10,
                          child: Text(basename(widget.file.path),
                            textHeightBehavior: TextHeightBehavior(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              color: Colors.white,
                              fontSize: (fullSize.width*1.5/100).floorToDouble(),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none
                            ),
                          ),
                        ),
                        SizedBox(
                          width: sideBarWidth/2-10,
                          // child: Text("${extension(widget.file.path).toUpperCase().substring(1)} · ${videoState.width}×${videoState.height} · ${durationToTime(videoState.duration)}",
                          // child: Text("${videoState.width}×${videoState.height} · ${durationToTime(videoState.duration)}",
                          child: Text("${videoSize.width.toInt()}×${videoSize.height.toInt()} · $videoDuration",
                            textAlign: TextAlign.right,
                            textHeightBehavior: TextHeightBehavior(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              color: Colors.white,
                              fontSize: (fullSize.width*0.95/100).floorToDouble(),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Column(
                      // children: [
                      //   for(var i = 0;i<12;i++) SideBarItem(
                      //       thumbnailPath: "assets/test/thumbnail.png",
                      //       videoPath: "C:\\Users\\blugo\\Videos\\[MV] 자다깨니 야자수 (寝起きヤシの木)｜Cover by 고세구.mp4",
                      //   )
                      // ],
                      children: sideItems,
                    ),
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}

String durationToTime(Duration duration) {
  var days = (duration.inDays).toString();
  var hour = (duration.inHours-((duration.inHours/24).floor()*60)).toString();
  var minute = (duration.inMinutes-((duration.inMinutes/60).floor()*60)).toString();
  var seconds = (duration.inSeconds-((duration.inSeconds/60).floor()*60)).toString();

  if(hour.length == 1) hour="0$hour";
  if(minute.length == 1) minute="0$minute";
  if(seconds.length == 1) seconds="0$seconds";

  var value = "";
  if(days != "0") value+="$days:";
  if(hour != "00") value+="$hour:";
  // if(minute != "00") value+="$minute:";
  value+="$minute:$seconds";
  return value;
}