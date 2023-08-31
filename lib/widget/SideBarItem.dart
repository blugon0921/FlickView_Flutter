import 'dart:async';
import 'dart:io';

import 'package:flick_view/FFmpeg.dart';
import 'package:flick_view/FFprobe.dart';
import 'package:flick_view/main.dart';
import 'package:flick_view/playing.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SideBarItem extends StatefulWidget {
  // final String thumbnailPath;
  final String videoPath;
  SideBarItem({
    super.key,
    // required this.thumbnailPath,
    required this.videoPath,
  });

  @override
  State<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<SideBarItem> {
  var videoDuration = "";
  var videoSize = Size(0, 0);
  final thumbnailsFolder = "${appData.path}\\thumbnails";

  var thumbnailPath = "";

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 1), (timer) { //Update State
      if(ffmpegFolder.ffmpeg().existsSync() && ffmpegFolder.ffprobe().existsSync()) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          var ffmpeg = FFmpeg(ffmpegFolder.ffmpeg().path);
          var ffprobe = FFprobe(ffmpegFolder.ffprobe().path);
          //Info
          var info = await ffprobe.info(widget.videoPath);
          if(info == null) {
            videoDuration = "0";
            videoSize = Size(0, 0);
          } else {
            videoDuration = durationToTime(Duration(milliseconds: (info.duration*1000).toInt()));
            videoSize = Size(info.size.width, info.size.height);
          }
          setState(() { });

          //Thumbnail
          var thumbnailFile = File("$thumbnailsFolder\\${basename(widget.videoPath)}.png");
          if(!thumbnailFile.existsSync()) {
            var thumbnailFile = await saveThumbnail(widget.videoPath, ffmpeg, ffprobe);
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
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var fullSize = MediaQuery.of(context).size;
    var sideBarWidth = (fullSize.width*25/100-3).floorToDouble();

    // var thumbnail = Image.asset("assets/images/unloadedThumbnail.png",
    //   height: fullSize.height*7.5/100,
    // );
    var thumbnail = Image.asset("assets/images/unloadedThumbnail.png",
        // width: (fullSize.width*7.5/100).floorToDouble(), // 20%
        height: fullSize.height*7.5/100
    );
    if(thumbnailPath != "") {
      thumbnail = Image.file(File(thumbnailPath),
        height: fullSize.height*7.5/100
      );
    }

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
                borderRadius: BorderRadius.circular(fullSize.height*0.01111111111111111111111111111111),
                // child: Image.asset(widget.thumbnailPath,
                child: thumbnail,
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