import 'dart:io';

import 'package:flutter/material.dart';

class FFmpeg {
  final String execPath;
  const FFmpeg(this.execPath);

  Future<File> saveScreenshot(String videoPath, double seconds, String saveName, {Size? scale}) async {
    // var command = "\"$execPath\" -i \"$videoPath\" -ss $seconds -vframes 1 $saveName";
    var command = "\"$execPath\" -i \"$videoPath\" -vframes 1 $saveName";
    if(scale != null) {
      // command = "\"$execPath\" -i \"$videoPath\" -ss $seconds -s ${scale.width.toInt()}x${scale.height.toInt()} -vframes 1 \"$saveName\"";
      command = "\"$execPath\" -i \"$videoPath\" -s ${scale.width.toInt()}x${scale.height.toInt()} -vframes 1 \"$saveName\"";
    }
    // print(command);
    var runned = await Process.run(command, []);
    return File(saveName);
  }
}