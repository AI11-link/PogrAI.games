import 'dart:math';
import 'package:game/ScriptManager.dart';
import 'package:game/SaveManager.dart';
import 'package:game/RouterManager.dart';
import 'package:game/ResAudioManager.dart';
import 'package:game/src/common.dart' as com;

var scr = getScriptManager();
var sv = getSaveManager();
var rm = getRouterManager();
var aud = getResAudioManager();
List<List<int>> winningCombos = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6] // diag
];

class TicTacToe {
  int _level = 1;
  int _fieldIndex = 0;
  List<String> _board = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '];
  String _humanSymbol = 'O';
  String _computerSymbol = 'X';
  String _currentPlayer = 'human';
  bool _gameOver = false;
  bool _isProcessing = false;
  int humanScore = 0;
  int computerScore = 0;

  List<String> get board => _board;
  bool get isGameOver => _gameOver;

  void startGame(int level) {
    _level = level;
    _fieldIndex = level - 1;
    com.setFieldIndex(_fieldIndex);
    scr.setText("world_main", _fieldIndex, "frame_1.text_level_value",
        level.toString());
    resetLevel();
  }

  void resetLevel() {
    _board = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '];
    _gameOver = false;
    _isProcessing = false;
    //print("START LEVEL: $_level");
    humanScore = sv.getValue("lvl$_level.u");
    computerScore = sv.getValue("lvl$_level.c");
    _showScore();
    Random random = Random();
    bool humanFirst = random.nextBool();
    // if (humanFirst) {
    //   print("HUMAN FIRST");
    // } else {
    //   print("COMPUTER FIRST");
    // }
    if (humanFirst) {
      _humanSymbol = 'X';
      _computerSymbol = 'O';
      _currentPlayer = 'human';
      scr.setText("world_main", _fieldIndex, "frame_4.text_turn_value", "your");
    } else {
      _humanSymbol = 'O';
      _computerSymbol = 'X';
      _currentPlayer = 'computer';
      scr.setText(
          "world_main", _fieldIndex, "frame_4.text_turn_value", "computer");
      _computerMove(false);
    }
    for (var i = 0; i < _board.length; i++) {
      scr.setAnimation(
          "world_main", _fieldIndex, "level_cell_$i.cell_anim_$i", "");
    }

    scr.stopTimer("levelTimer");
    scr.createTimer(
        "levelTimer", 1, "game::src/common::timerTick", {"count": 0});
    com.timerTick(0);
  }

  void pauseGame() {
    scr.pauseTimer("levelTimer");
  }

  void resumeGame() {
    scr.resumeTimer("levelTimer");
  }

  void humanMove(int cell) {
    if (_currentPlayer != 'human' || _gameOver || _isProcessing) {
      return;
    }
    if (_makeMove(cell)) {
      if (!_gameOver && _currentPlayer == 'computer') {
        _computerMove(true);
      }
    }
  }

  Future<void> _computerMove(bool isDelayExist) async {
    if (_currentPlayer != 'computer' || _gameOver) {
      return;
    }
    _lockCells();
    if (isDelayExist) {
      await Future.delayed(Duration(milliseconds: 1500));
    } else {
      await Future.delayed(Duration(milliseconds: 500));
    }

    // 1. Check if the computer can win
    int winMove = _getWinningMove(_computerSymbol);
    if (winMove != -1) {
      _makeMove(winMove);
      _unlockCells();
      return;
    }

    // 2. Check if an opponent's move needs to be blocked
    int blockMove = _getWinningMove(_humanSymbol);
    if (blockMove != -1) {
      _makeMove(blockMove);
      _unlockCells();
      return;
    }

    // Count filled cells to detect opening moves
    int movesCount = 0;
    for (var cell in _board) {
      if (cell != ' ') {
        movesCount++;
      }
    }
    List<int> corners = [0, 2, 6, 8];
    List<int> sides = [1, 3, 5, 7];

    // 3. Strategic opening: counter corner-first by taking a side
    if (movesCount == 1) {
      // Human has played exactly one move; find its index manually
      int humanMove = -1;
      for (int i = 0; i < _board.length; i++) {
        if (_board[i] == _humanSymbol) {
          humanMove = i;
          break;
        }
      }
      if (humanMove != -1 && corners.contains(humanMove)) {
        // Human started in corner -> take a random side to avoid fork
        sides.shuffle();
        for (var side in sides) {
          if (_board[side] == ' ') {
            _makeMove(side);
            _unlockCells();
            return;
          }
        }
      }
    }

    // 4. Otherwise, take the center if available
    if (_board[4] == ' ') {
      _makeMove(4);
      _unlockCells();
      return;
    }

    // 5. Fallback: take a random corner
    corners.shuffle();
    for (var corner in corners) {
      if (_board[corner] == ' ') {
        _makeMove(corner);
        _unlockCells();
        return;
      }
    }

    // 6. Last resort: take a random side
    sides.shuffle();
    for (var side in sides) {
      if (_board[side] == ' ') {
        _makeMove(side);
        _unlockCells();
        return;
      }
    }

    _unlockCells();
  }

  bool _makeMove(int cell) {
    // print("Move $_currentPlayer: $cell");
    if (cell < 0 || cell > 8 || _board[cell] != ' ') {
      return false;
    }
    String symbol = _currentPlayer == 'human' ? _humanSymbol : _computerSymbol;
    _board[cell] = symbol;
    if (symbol == 'X') {
      _setX(cell);
    } else {
      _setO(cell);
    }
    if (_checkWin(symbol)) {
      _gameOver = true;
      _handleEnd(_currentPlayer == 'human');
    } else if (_checkDraw()) {
      _gameOver = true;
      _handleEnd(null); // draw
    } else {
      _switchPlayer();
    }
    return true;
  }

  void _switchPlayer() {
    aud.playSound("click", {});
    if (_currentPlayer == 'human') {
      _currentPlayer = 'computer';
      scr.setText(
          "world_main", _fieldIndex, "frame_4.text_turn_value", "computer");
    } else {
      _currentPlayer = 'human';
      scr.setText("world_main", _fieldIndex, "frame_4.text_turn_value", "your");
    }
  }

  int _getWinningMove(String symbol) {
    for (var combo in winningCombos) {
      int count = 0;
      int emptyIndex = -1;
      for (var i in combo) {
        if (_board[i] == symbol) {
          count++;
        } else if (_board[i] == ' ') {
          emptyIndex = i;
        }
      }
      if (count == 2 && emptyIndex != -1) {
        return emptyIndex;
      }
    }
    return -1;
  }

  bool _checkWin(String symbol) {
    for (var combo in winningCombos) {
      if (_board[combo[0]] == symbol &&
          _board[combo[1]] == symbol &&
          _board[combo[2]] == symbol) {
        return true;
      }
    }
    return false;
  }

  bool _checkDraw() {
    return !_board.contains(' ');
  }

  void _lockCells() {
    _isProcessing = true;
  }

  void _unlockCells() {
    _isProcessing = false;
  }

  void _setX(int cell) {
    scr.setAnimation(
        "world_main", _fieldIndex, "level_cell_$cell.cell_anim_$cell", "x");
  }

  void _setO(int cell) {
    scr.setAnimation(
        "world_main", _fieldIndex, "level_cell_$cell.cell_anim_$cell", "o");
  }

  void _showScore() {
    scr.setText("world_main", _fieldIndex, "frame_2.text_score_value",
        "$humanScore:$computerScore");
  }

  Future<void> _handleEnd(bool? humanWon) async {
    aud.stopSound();
    if (humanWon == true) {
      // print("HUMAN WIN");
      aud.playSound("win", {});
      humanScore += 1;
      sv.setValue("lvl$_level.u", humanScore, isSave: true);
    } else if (humanWon == false) {
      // print("COMPUTER WIN");
      aud.playSound("lose", {});
      computerScore += 1;
      sv.setValue("lvl$_level.c", computerScore, isSave: true);
    } else {
      // print("DRAW");
      aud.playSound("draw", {});
    }
    _showScore();
    scr.stopTimer("levelTimer");
    await Future.delayed(Duration(milliseconds: 2000));
    if (humanWon == true) {
      rm.showWindow("win_window", {});
    } else if (humanWon == false) {
      rm.showWindow("lose_window", {});
    } else {
      resetLevel();
    }
  }
}
