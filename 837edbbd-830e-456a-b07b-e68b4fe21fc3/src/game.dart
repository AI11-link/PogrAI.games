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
  int _fieldSize = 3;
  int _winLength = 3;
  List<String> _board = <String>[];
  String _humanSymbol = 'o';
  String _computerSymbol = 'x';
  String _currentPlayer = 'human';
  bool _gameOver = false;
  bool _isProcessing = false;
  int humanScore = 0;
  int computerScore = 0;
  List<List<int>> _winningCombos = [];
  List<int>? _winningLine;

  List<String> get board => _board;
  bool get isGameOver => _gameOver;

  void startGame(int level) {
    _level = level;
    _fieldIndex = level - 1;
    _fieldSize = 3 + 2 * (level - 1);
    _winLength = level + 2;
    com.setFieldIndex(_fieldIndex);
    scr.setText("world_main", _fieldIndex, "frame_1.text_level_value",
        level.toString());
    _generateWinningCombos();
    resetLevel();
  }

  void _generateWinningCombos() {
    _winningCombos.clear();
    // Rows
    for (int i = 0; i < _fieldSize; i++) {
      for (int j = 0; j <= _fieldSize - _winLength; j++) {
        List<int> combo = [];
        for (int k = 0; k < _winLength; k++) {
          combo.add(i * _fieldSize + j + k);
        }
        _winningCombos.add(combo);
      }
    }
    // Columns
    for (int j = 0; j < _fieldSize; j++) {
      for (int i = 0; i <= _fieldSize - _winLength; i++) {
        List<int> combo = [];
        for (int k = 0; k < _winLength; k++) {
          combo.add((i + k) * _fieldSize + j);
        }
        _winningCombos.add(combo);
      }
    }
    // Main diagonal
    for (int i = 0; i <= _fieldSize - _winLength; i++) {
      for (int j = 0; j <= _fieldSize - _winLength; j++) {
        List<int> combo = [];
        for (int k = 0; k < _winLength; k++) {
          combo.add((i + k) * _fieldSize + (j + k));
        }
        _winningCombos.add(combo);
      }
    }
    // Secondary diagonals
    for (int i = 0; i <= _fieldSize - _winLength; i++) {
      for (int j = _winLength - 1; j < _fieldSize; j++) {
        List<int> combo = [];
        for (int k = 0; k < _winLength; k++) {
          combo.add((i + k) * _fieldSize + (j - k));
        }
        _winningCombos.add(combo);
      }
    }
  }

  int getLevel() {
    return _level;
  }

  void resetLevel() {
    _board = <String>[];
    for (var i = 0; i < _fieldSize * _fieldSize; i++) {
      _board.add(" ");
    }
    _gameOver = false;
    _isProcessing = false;
    // print("START LEVEL: $_level");
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
      _humanSymbol = 'x';
      _computerSymbol = 'o';
      _currentPlayer = 'human';
      scr.setText("world_main", _fieldIndex, "frame_4.text_turn_value", "your");
    } else {
      _humanSymbol = 'o';
      _computerSymbol = 'x';
      _currentPlayer = 'computer';
      scr.setText(
          "world_main", _fieldIndex, "frame_4.text_turn_value", "computer");
      _computerMove(false);
    }
    for (var i = 0; i < _fieldSize * _fieldSize; i++) {
      scr.setAnimation(
          "world_main", _fieldIndex, "level_cell_$i.cell_anim_$i", "");
    }

    scr.stopTimer("timerLevel$_level");
    scr.createTimer(
        "timerLevel$_level", 1, "game::src/common::timerTick", {"count": 0});
    com.timerTick(0);
  }

  void pauseGame() {
    scr.pauseTimer("timerLevel$_level");
  }

  void resumeGame() {
    scr.resumeTimer("timerLevel$_level");
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

    // 3. For level 1: prevent a "fork" by playing on the side if the opponent has taken the opposite corners.
    if (_level == 1) {
      List<List<int>> oppositeCorners = [
        [0, 8],
        [2, 6]
      ];
      for (var pair in oppositeCorners) {
        if (_board[pair[0]] == _humanSymbol &&
            _board[pair[1]] == _humanSymbol) {
          if (_board[4] == _computerSymbol) {
            List<int> sides = [1, 3, 5, 7]; // Cells on the sides
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
      }
    }

    // 4. For levels 2 and above: block potential threats with the best move
    if (_level >= 2) {
      int bestBlockMove = _getBestBlockingMove();
      if (bestBlockMove != -1) {
        _makeMove(bestBlockMove);
        _unlockCells();
        return;
      }
    }

    // 5. Random move with probability
    final rnd = Random().nextDouble();
    if (rnd < 0.2 / _level) {
      _makeRandomMove();
      _unlockCells();
      return;
    }

    // 6. Take the center if available
    int center = (_fieldSize ~/ 2) * _fieldSize + (_fieldSize ~/ 2);
    if (_board[center] == ' ') {
      _makeMove(center);
      _unlockCells();
      return;
    }

    // 7. Take a random corner
    List<int> corners = [
      0,
      _fieldSize - 1,
      (_fieldSize - 1) * _fieldSize,
      _fieldSize * _fieldSize - 1
    ];
    corners.shuffle();
    for (var corner in corners) {
      if (_board[corner] == ' ') {
        _makeMove(corner);
        _unlockCells();
        return;
      }
    }

    // 8. Take a random available cell
    List<int> available = [];
    for (int i = 0; i < _fieldSize * _fieldSize; i++) {
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
    if (cell < 0 || cell >= _fieldSize * _fieldSize || _board[cell] != ' ') {
      return false;
    }
    String symbol = _currentPlayer == 'human' ? _humanSymbol : _computerSymbol;
    _board[cell] = symbol;
    if (symbol == 'x') {
      _setX(cell);
    } else {
      _setO(cell);
    }
    if (_checkWin(symbol)) {
      _gameOver = true;
      // Animation for winning line
      if (_winningLine != null) {
        for (var cell in _winningLine!) {
          scr.setAnimation(
              "world_main",
              _fieldIndex,
              "level_cell_$cell.cell_anim_$cell",
              _currentPlayer == 'human' ? _humanSymbol : _computerSymbol);
        }
      }
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

  int _getBestBlockingMove() {
    // Dictionary for counting threats by cells
    Map<int, int> blockCounts = {};

    // We go through all the winning combinations
    int comboIndex = 0;
    while (comboIndex < _winningCombos.length) {
      List<int> combo = _winningCombos[comboIndex];
      int humanCount = 0;
      List<int> emptySpots = [];

      // We count the opponent's symbols and empty cells in the combination
      int spotIndex = 0;
      while (spotIndex < combo.length) {
        int spot = combo[spotIndex];
        if (_board[spot] == _humanSymbol) {
          humanCount = humanCount + 1;
        } else if (_board[spot] == ' ') {
          emptySpots.add(spot);
        }
        spotIndex = spotIndex + 1;
      }

      // If the opponent almost won (2 out of 3), update the threat counter
      if (humanCount == _winLength - 2 && emptySpots.length == 2) {
        int emptyIndex = 0;
        while (emptyIndex < emptySpots.length) {
          int spot = emptySpots[emptyIndex];
          if (blockCounts.containsKey(spot)) {
            blockCounts[spot] = blockCounts[spot]! + 1;
          } else {
            blockCounts[spot] = 1;
          }
          emptyIndex = emptyIndex + 1;
        }
      }
      comboIndex = comboIndex + 1;
    }

    // If the dictionary is empty, return -1
    if (blockCounts.isEmpty) {
      return -1;
    }

    // Find the cell with the maximum number of threats
    int maxCount = -1;
    int bestSpot = -1;
    int keyIndex = 0;
    List<int> keys = [];
    for (final entity in blockCounts.entries) {
      keys.add(entity.key);
    }
    while (keyIndex < keys.length) {
      int key = keys[keyIndex];
      int value = blockCounts[key]!;
      if (value > maxCount) {
        maxCount = value;
        bestSpot = key;
      }
      keyIndex = keyIndex + 1;
    }

    return bestSpot;
  }

  void _makeRandomMove() {
    List<int> available = [];
    for (int i = 0; i < _fieldSize * _fieldSize; i++) {
      if (_board[i] == ' ') {
        available.add(i);
      }
    }
    if (available.isNotEmpty) {
      available.shuffle();
      // print("Random move ${available[0]}");
      _makeMove(available[0]);
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
      if (count == _winLength - 1 && emptyIndex != -1) {
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
        _winningLine = combo;
        // print("WIN LINE: $combo");
        return true;
      }
    }
    _winningLine = null;
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
    scr.stopTimer("timerLevel$_level");
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
