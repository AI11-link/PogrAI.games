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

class TicTacToe {
  int _level = 1;
  int _fieldIndex = 0;
  int _N = 3;
  List<String> _board = <String>[];
  String _humanSymbol = 'O';
  String _computerSymbol = 'X';
  String _currentPlayer = 'human';
  bool _gameOver = false;
  bool _isProcessing = false;
  int humanScore = 0;
  int computerScore = 0;
  List<List<int>> _winningCombos = [];

  List<String> get board => _board;
  bool get isGameOver => _gameOver;

  void startGame(int level) {
    _level = level;
    _fieldIndex = level - 1;
    _N = 3 + 2 * (level - 1);
    com.setFieldIndex(_fieldIndex);
    scr.setText("world_main", _fieldIndex, "frame_1.text_level_value",
        level.toString());
    _generateWinningCombos();
    resetLevel();
  }

  void _generateWinningCombos() {
    _winningCombos.clear();
    // Rows
    for (int i = 0; i < _N; i++) {
      List<int> row = [];
      for (int j = 0; j < _N; j++) {
        row.add(i * _N + j);
      }
      _winningCombos.add(row);
    }
    // Columns
    for (int j = 0; j < _N; j++) {
      List<int> col = [];
      for (int i = 0; i < _N; i++) {
        col.add(i * _N + j);
      }
      _winningCombos.add(col);
    }
    // Main diagonal
    List<int> mainDiag = [];
    for (int i = 0; i < _N; i++) {
      mainDiag.add(i * _N + i);
    }
    _winningCombos.add(mainDiag);
    // Secondary diagonal
    List<int> antiDiag = [];
    for (int i = 0; i < _N; i++) {
      antiDiag.add(i * _N + (_N - 1 - i));
    }
    _winningCombos.add(antiDiag);
  }

  void resetLevel() {
    _board = <String>[];
    for (var i = 0; i < _N * _N; i++) {
      _board.add(" ");
    }
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
    for (var i = 0; i < _N * _N; i++) {
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

    // Take the center if available
    int center = (_N ~/ 2) * _N + (_N ~/ 2);
    if (_board[center] == ' ') {
      _makeMove(center);
      _unlockCells();
      return;
    }

    // Take a random angle
    List<int> corners = [0, _N - 1, (_N - 1) * _N, _N * _N - 1];
    corners.shuffle();
    for (var corner in corners) {
      if (_board[corner] == ' ') {
        _makeMove(corner);
        _unlockCells();
        return;
      }
    }

    // Take a random available cell
    List<int> available = [];
    for (int i = 0; i < _N * _N; i++) {
      if (_board[i] == ' ') {
        available.add(i);
      }
    }
    if (available.isNotEmpty) {
      available.shuffle();
      _makeMove(available.first);
      _unlockCells();
      return;
    }

    _unlockCells();
  }

  bool _makeMove(int cell) {
    // print("Move $_currentPlayer: $cell");
    if (cell < 0 || cell >= _N * _N || _board[cell] != ' ') {
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
    for (var combo in _winningCombos) {
      int count = 0;
      int emptyIndex = -1;
      for (int i in combo) {
        if (_board[i] == symbol) {
          count = count + 1;
        } else if (_board[i] == ' ') {
          emptyIndex = i;
        }
      }
      if (count == _N - 1 && emptyIndex != -1) {
        return emptyIndex;
      }
    }
    return -1;
  }

  bool _checkWin(String symbol) {
    for (var combo in _winningCombos) {
      bool win = true;
      for (var pos in combo) {
        if (_board[pos] != symbol) {
          win = false;
          break;
        }
      }
      if (win) {
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
