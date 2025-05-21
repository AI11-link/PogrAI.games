import 'package:game/RouterManager.dart';
import 'package:game/ScriptManager.dart';
import 'package:game/src/game.dart';

RouterManager rt = getRouterManager();
ScriptManager scr = getScriptManager();
TicTacToe? _game = null;

void startLevel(int level) {
  // TODO implement showing levels 2 and 3
  rt.showWindow("gameplay", {'content': 'world_main.game_level_1'});

  if (_game == null) {
    _game = TicTacToe();
    _game.startGame(level);
  }
}

void humanMove(int cell) {
  if (_game != null) {
    _game.humanMove(cell);
  }
}

void resetLevel() {
  if (_game != null) {
    _game.resetLevel();
  }
}

void back(String closedWindow) {
  if (closedWindow == "win_window" || closedWindow == "lose_window") {
    resetLevel();
  }
}
