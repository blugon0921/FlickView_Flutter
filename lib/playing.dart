import 'dart:async';
import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flick_view/FFprobe.dart';
import 'package:flick_view/main.dart';
import 'package:flick_view/widget/SideBarItem.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

  var videoDuration = "";
  var videoSize = Size(0, 0);

  @override
  void initState() {
    player.open(Media(widget.file.path));
    setWindowTitle("Flick View | ${basename(widget.file.path)}");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addSideItems();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // final Directory root = findRoot(await getApplicationDocumentsDirectory());
      // print(root.path);
      Directory directory = Directory("./");
      print(directory.path);
      var items = (await dirContents(directory)).whereType<File>();
      for (var value in items) {
        print(value.path);
      }
      // var dbPath = join(directory.path, "app.txt");
      // ByteData data = await rootBundle.load("assets/windows/ffprobe.exe");
      // List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // (await File(dbPath).writeAsBytes(bytes);

      var path = "assets/windows/ffprobe.exe";
      if(Platform.isMacOS) path = "assets/macos/ffprobe";
      if(Platform.isLinux) path = "assets/linux/ffprobe";
      // var ffprobe = FFprobe(path);
      var ffprobe = FFprobe("C:\\CodingFile\\Flutter\\FlickView\\assets\\ffmpeg\\windows\\ffprobe.exe");
      var duration = (await ffprobe.getDuration(widget.file.path));
      var size = (await ffprobe.getSize(widget.file.path));
      duration ??= 0;
      size ??= Size(0, 0);
      videoDuration = durationToTime(Duration(milliseconds: (duration*1000).toInt()));
      videoSize = Size(size.width, size.height);
      setState(() { });
    });
    // Timer.periodic(Duration(milliseconds: 1), (timer) { //Update State
    //   if(player.state.width != null) {
    //     setState(() {
    //       videoState = player.state;
    //     });
    //     timer.cancel();
    //   }
    // });
    super.initState();
  }

  _addSideItems() async {
    var items = (await dirContents(widget.file.parent)).whereType<File>();
    for (var value in items) {
      final mimeType = lookupMimeType(value.path);
      if(mimeType == null) continue;
      if(!mimeType.startsWith("video")) continue;
      sideItems.add(SideBarItem(
        // thumbnailPath: basename(value.path),
        thumbnailPath: "assets/test/thumbnail.png",
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
            child: SingleChildScrollView (
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Image.asset("assets/test/thumbnail.png",
                    width: sideBarWidth,
                  ),
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