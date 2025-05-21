import 'package:game/ScriptManager.dart';

var scr = getScriptManager();
int fi = 0;

void setFieldIndex(int fieldIndex) {
  fi = fieldIndex;
}

void timerTick(int count) {
  final secondsCounter = (count % 3600).toInt();
  final minutes = secondsCounter ~/ 60;
  final seconds = (secondsCounter % 60).toInt();
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  final formatted = '$mm:$ss';
  scr.setText("world_main", fi, "frame_3.text_time_value", formatted);
}
