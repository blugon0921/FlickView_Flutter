import 'dart:io';

import 'package:flutter/material.dart';

class FFprobe {
  final String execPath;
  const FFprobe(this.execPath);

  Future<ProbeInfo?> info(String videoPath) async {
    var duration = await getDuration(videoPath);
    var size = await getSize(videoPath);
    if(duration == null || size == null) {
      return null;
    } else {
      return ProbeInfo(
        duration,
        size
      );
    }
  }

  Future<double?> getDuration(String videoPath) async {
    var runned = await Process.run("\"$execPath\" -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"$videoPath\"", []);
    if(runned.stdout != "" && runned.stderr == "") {
      return double.parse(runned.stdout.toString());
    } else {
      return null;
    }
  }

  Future<Size?> getSize(String videoPath) async {
    var runned = await Process.run("\"$execPath\" -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 \"$videoPath\"", []);
    if(runned.stdout != "" && runned.stderr == "") {
      var size = runned.stdout.toString().split("x");
      return Size(double.parse(size[0]), double.parse(size[1]));
    } else {
      return null;
    }
  }
}

class ProbeInfo {
  final double duration;
  final Size size;
  const ProbeInfo(
    this.duration,
    this.size
  );
}