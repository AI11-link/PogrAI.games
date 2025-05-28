import 'package:game/RouterManager.dart';
import 'package:game/ScriptManager.dart';
import 'package:game/ResAudioManager.dart';
import 'package:game/src/game.dart';
import 'package:game/src/common.dart' as com;

RouterManager rt = getRouterManager();
ScriptManager scr = getScriptManager();
ResAudioManager aud = getResAudioManager();
TicTacToe? _level1 = null;
TicTacToe? _level2 = null;
TicTacToe? _level3 = null;
TicTacToe? _currentLevel = null;

void startLevel(int level) {
  rt.showWindow("gameplay", {'content': 'world_main.game_level_$level'});

  if (level == 1) {
    if (_level1 == null) {
      _level1 = TicTacToe();
      _level1.startGame(level);
    }
    _currentLevel = _level1;
  } else if (level == 2) {
    if (_level2 == null) {
      _level2 = TicTacToe();
      _level2.startGame(level);
    }
    _currentLevel = _level2;
  } else if (level == 3) {
    if (_level3 == null) {
      _level3 = TicTacToe();
      _level3.startGame(level);
    }
    _currentLevel = _level3;
  }
  com.setFieldIndex(level - 1);
  resumeGame();
}

void humanMove(int cell) {
  if (_currentLevel != null) {
    _currentLevel.humanMove(cell);
  }
}

void resetLevel() {
  if (_currentLevel != null) {
    _currentLevel.resetLevel();
  }
}

void pauseGame() {
  if (_currentLevel != null) {
    _currentLevel.pauseGame();
  }
}

void resumeGame() {
  if (_currentLevel != null) {
    _currentLevel.resumeGame();
  }
}

void back(String closedWindow) {
  if (closedWindow == "win_window" || closedWindow == "lose_window") {
    resetLevel();
  } else if (closedWindow == "gameplay") {
    if (_currentLevel != null) {
      _currentLevel.pauseGame();
    }
    if (aud.getIsPlayMusic({})) {
      aud.playMusic("main_menu_music", {});
    } else {
      aud.stopMusic({});
    }
  } else if (closedWindow == "pause_game_window") {
    if (_currentLevel != null) {
      _currentLevel.resumeGame();
    }
  }
}
