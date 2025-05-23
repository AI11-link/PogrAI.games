import 'package:game/RouterManager.dart';
import 'package:game/ScriptManager.dart';
import 'package:game/ResAudioManager.dart';
import 'package:game/src/game.dart';

RouterManager rt = getRouterManager();
ScriptManager scr = getScriptManager();
ResAudioManager aud = getResAudioManager();
TicTacToe? _game = null;

void startLevel(int level) {
  // TODO implement showing levels 2 and 3
  rt.showWindow("gameplay", {'content': 'world_main.game_level_1'});

  if (_game == null) {
    _game = TicTacToe();
    _game.startGame(level);
  }
  resumeGame();
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

void pauseGame() {
  if (_game != null) {
    _game.pauseGame();
  }
}

void resumeGame() {
  if (_game != null) {
    _game.resumeGame();
  }
}

void back(String closedWindow) {
  if (closedWindow == "win_window" || closedWindow == "lose_window") {
    resetLevel();
  } else if (closedWindow == "gameplay") {
    if (_game != null) {
      _game.pauseGame();
    }
    if (aud.getIsPlayMusic({})) {
      aud.playMusic("main_menu_music", {});
    } else {
      aud.stopMusic({});
    }
  } else if (closedWindow == "pause_game_window") {
    if (_game != null) {
      _game.resumeGame();
    }
  }
}
