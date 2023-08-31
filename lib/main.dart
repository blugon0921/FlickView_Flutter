import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flick_view/playing.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

late Directory appData; //앱데이터
late FFmpegFolder ffmpegFolder;

void main() async {
  appData = await getApplicationSupportDirectory();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if(Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    setWindowTitle("Flick View");
    Screen screen = (await getScreenList())[0];
    Rect frame = screen.frame;

    setWindowMinSize(Size(frame.width*(845/1920), frame.height*(492/1080)));
    setWindowMaxSize(Size(frame.width, frame.height));
    setWindowFrame(Rect.fromCenter(center: frame.center, width: frame.width*(1547/1920), height: frame.height*(900/1080)));
    print("${frame.width*(1547/1920)} ${frame.height*(900/1080)}");
  }
  runApp(const MyScreen());
  if(!appData.existsSync()) {
    appData.createSync(recursive: true);
  }
  ffmpegFolder = FFmpegFolder(appData);
  if(!ffmpegFolder.directory().existsSync()) {
    await ffmpegFolder.downloadAndUnzip(getOs());
  }
}

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  @override
  State<MyScreen> createState() => MyApp();
}

class MyApp extends State<MyScreen> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flick View",
      theme: ThemeData(
        fontFamily: "Pretendard",
        brightness: Brightness.dark,
      ),
      home: Container(
        color: Color(0xff1E1F22),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("드래그 앤 드롭",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none
              ),
            ),
            Container(
              margin: EdgeInsets.all(40),
              child: Text("OR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xFF00B2FF)),
                padding: MaterialStatePropertyAll(EdgeInsets.all(22)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ))
              ),
              child: Text("클릭하여 열기",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none
                ),
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.video
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  runApp(PlayingScreen(file: file));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

OS getOs() {
  if(Platform.isWindows) {
    return OS.windows;
  } else if(Platform.isMacOS) {
    return OS.macos;
  } else {
    return OS.linux;
  }
}

class FFmpegFolder {
  final Directory appDataFolder;
  const FFmpegFolder(this.appDataFolder);

  File ffmpeg() {
    if(Platform.isWindows) {
      return File("${appDataFolder.path}\\ffmpeg\\ffmpeg.exe");
    } else {
      return File("${appDataFolder.path}\\ffmpeg\\ffmpeg");
    }
  }

  File ffprobe() {
    if(Platform.isWindows) {
      return File("${appDataFolder.path}\\ffmpeg\\ffprobe.exe");
    } else {
      return File("${appDataFolder.path}\\ffmpeg\\ffprobe");
    }
  }

  Directory directory() {
    return Directory("${appDataFolder.path}\\ffmpeg");
  }

  Future<void> downloadAndUnzip(OS os, {bool endRemove = true}) async {
    if(!File("${appData.path}\\ffmpeg.tar.gz").existsSync()) {
      // var url = "https://storage.blugon.kr/Program/FFmpeg/${os.name}.tar.gz";
      var url = "https://storage.blugon.kr/Program/FFmpeg/${os.name}.zip";
      // var result = await Dio().download(url, "${appData.path}\\ffmpeg.tar.gz");
      await Dio().download(url, "${appData.path}\\ffmpeg.zip");
    }
    // var file = File("${appData.path}\\ffmpeg.tar.gz");
    var file = File("${appData.path}\\ffmpeg.zip");
    final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
    var directory = Directory("${appData.path}\\ffmpeg");
    directory.createSync(recursive: true);

    Isolate.spawn((message) {
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File("${directory.path}\\$filename")
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory("${directory.path}\\$filename").create(recursive: true);
        }
      }

      if(endRemove) {
        file.delete(recursive: true);
      }
    }, false);
  }
}

enum OS {
  windows,
  macos,
  linux,
}