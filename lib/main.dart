import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flick_view/playing.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_size/window_size.dart';
import 'package:path_provider/path_provider.dart';

// final testVideoFile = File("C:\\Users\\blugo\\Videos\\[MV] 자다깨니 야자수 (寝起きヤシの木)｜Cover by 고세구.mp4");
//Directory directory = await getApplicationCacheDirectory(); //앱데이터

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if(Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    setWindowTitle("Flick View");
    Screen screen = (await getScreenList())[0];
    Rect frame = screen.frame;

    setWindowMinSize(Size(frame.width*(600/1920), frame.height*(369/1080)));
    setWindowFrame(Rect.fromCenter(center: frame.center, width: frame.width*(1547/1920), height: frame.height*(900/1080)));
    print("${frame.width*(1547/1920)} ${frame.height*(900/1080)}");
  }
  runApp(const MyScreen());
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