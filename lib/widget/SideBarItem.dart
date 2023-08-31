import 'dart:async';
import 'dart:io';

import 'package:flick_view/FFprobe.dart';
import 'package:flick_view/main.dart';
import 'package:flick_view/playing.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart';

class SideBarItem extends StatefulWidget {
  final String thumbnailPath;
  final String videoPath;
  SideBarItem({
    super.key,
    required this.thumbnailPath,
    required this.videoPath,
  });

  @override
  State<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<SideBarItem> {
  // final player = Player();
  // late final controller = VideoController(player);
  // late var videoState = PlayerState();

  var videoDuration = "";
  var videoSize = Size(0, 0);

  @override
  void initState() {
    // player.open(Media(widget.videoPath), play: false);
    // Timer.periodic(Duration(milliseconds: 1), (timer) { //Update State
    //   if(player.state.width != null) {
    //     setState(() {
    //       videoState = player.state;
    //     });
    //     timer.cancel();
    //     player.dispose();
    //     // print("${videoState.width} x ${videoState.height}");
    //   }
    // });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var path = "assets/windows/ffprobe.exe";
      if(Platform.isMacOS) path = "assets/macos/ffprobe";
      if(Platform.isLinux) path = "assets/linux/ffprobe";
      // var ffprobe = FFprobe(path);
      var ffprobe = FFprobe("C:\\CodingFile\\Flutter\\FlickView\\assets\\ffmpeg\\windows\\ffprobe.exe");
      var duration = (await ffprobe.getDuration(widget.videoPath));
      var size = (await ffprobe.getSize(widget.videoPath));
      duration ??= 0;
      size ??= Size(0, 0);
      videoDuration = durationToTime(Duration(milliseconds: (duration*1000).toInt()));
      videoSize = Size(size.width, size.height);
      setState(() { });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fullSize = MediaQuery.of(context).size;
    var sideBarWidth = (fullSize.width*25/100-3).floorToDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      width: sideBarWidth,
      height: fullSize.height*10/100,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Color(0xFF33363D)),
          padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          )),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(sideBarWidth*0.02638522427440633245382585751979),
                borderRadius: BorderRadius.circular(fullSize.height*0.01111111111111111111111111111111),
                child: Image.asset(widget.thumbnailPath,
                  // width: (fullSize.width*7.5/100).floorToDouble(), // 20%
                  height: fullSize.height*7.5/100
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5, left: 10),
                child: Column(
                  children: [
                    Align(alignment: Alignment.centerLeft,
                      child: Text(basename(widget.videoPath),
                        textHeightBehavior: TextHeightBehavior(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            color: Colors.white,
                            fontSize: (fullSize.height*1.9/100).floorToDouble(),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none
                        ),
                      ),
                    ),
                    Align(alignment: Alignment.centerLeft,
                      // child: Text("${extension(widget.videoPath).toUpperCase().substring(1)} · ${videoState.width}×${videoState.height}",
                      child: Text("${extension(widget.videoPath).toUpperCase().substring(1)} · ${videoSize.width.toInt()}×${videoSize.height.toInt()}",
                        textHeightBehavior: TextHeightBehavior(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            color: Colors.white,
                            fontSize: (fullSize.height*1.6/100).floorToDouble(),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none
                        ),
                      ),
                    ),
                    Align(alignment: Alignment.centerLeft,
                      // child: Text(durationToTime(videoState.duration),
                      child: Text(videoDuration,
                        textHeightBehavior: TextHeightBehavior(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            color: Colors.white,
                            fontSize: (fullSize.height*1.6/100).floorToDouble(),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none
                        ),
                      ),
                    )
                  ],
                ),
              )
            ),
            // Video(
            //   controller: controller,
            //   width: 0,
            //   height: 0,
            //   controls: AdaptiveVideoControls,
            //   fill: Color(0xff1E1F22),
            //   filterQuality: FilterQuality.low,
            //   aspectRatio: 0,
            // )
          ],
        ),
        onPressed: () async {
          File file = File(widget.videoPath);
          runApp(MyScreen());
          runApp(PlayingScreen(file: file));
        },
      ),
    );
  }
}