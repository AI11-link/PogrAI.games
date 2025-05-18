import 'package:game/ScriptManager.dart';
import 'package:game/src/game.dart';

var scr = getScriptManager();
var fi = 0;
String currentPlayer = 'human'; // 'human' or 'computer'
bool gameOver = false;

void level(int level) {
  print("GAMEPLAY" + level.toString());

  fi = 0; //level - 1; TODO
  scr.setText("world_main", fi, "frame_1.text_level_value", level.toString());

  scr.stopTimer("levelTimer");
  scr.createTimer("levelTimer", 1, "field_game_level_1::src/level::timerTick",
      {"count": 0});
  timerTick(0);

  TicTacToe game = TicTacToe();
  game.startGame();
}

void timerTick(int count) {
  print("TIMERTICK " + count.toString());
  final secondsCounter = (count % 3600).toInt();
  final minutes = secondsCounter ~/ 60;
  final seconds = (secondsCounter % 60).toInt();
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  final formatted = '$mm:$ss';
  scr.setText("world_main", fi, "frame_3.text_time_value", formatted);
}
