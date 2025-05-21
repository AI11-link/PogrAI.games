import 'package:game/RouterManager.dart';
import 'package:game/ScriptManager.dart';
import 'package:game/src/game.dart';

RouterManager rt = getRouterManager();
ScriptManager scr = getScriptManager();
int _fi = 0;
TicTacToe? _game = null;

void startLevel(int level) {
  // TODO implement showing levels 2 and 3
  rt.showWindow("gameplay", {'content': 'world_main.game_level_1'});
  _setLevel(level);
}

void humanMove(int cell) {
  if (_game != null) {
    _game.humanMove(cell);
  }
}

void _setLevel(int level) {
  _fi = 0; //level - 1; TODO
  scr.setText("world_main", _fi, "frame_1.text_level_value", level.toString());

  scr.stopTimer("levelTimer");
  scr.createTimer("levelTimer", 1, "game::src/main::_timerTick", {"count": 0});
  _timerTick(0);

  _game = TicTacToe();
  _game.startGame(level);
}

void _timerTick(int count) {
  final secondsCounter = (count % 3600).toInt();
  final minutes = secondsCounter ~/ 60;
  final seconds = (secondsCounter % 60).toInt();
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  final formatted = '$mm:$ss';
  scr.setText("world_main", _fi, "frame_3.text_time_value", formatted);
}
