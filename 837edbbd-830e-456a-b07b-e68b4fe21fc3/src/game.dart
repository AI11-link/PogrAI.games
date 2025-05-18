import 'dart:math';

class TicTacToe {
  List<String> _board = List.filled(9, ' ');
  String _humanSymbol = '0';
  String _computerSymbol = 'X';
  String _currentPlayer = 'human';
  bool _gameOver = false;
  bool _isProcessing = false;
  int humanScore = 0;
  int computerScore = 0;

  List<String> get board => _board;
  bool get isGameOver => _gameOver;

  void startGame() {
    _board = List.filled(9, ' ');
    _gameOver = false;
    _isProcessing = false;
    Random random = Random();
    bool humanFirst = random.nextBool();
    if (humanFirst) {
      _humanSymbol = 'X';
      _computerSymbol = 'O';
      _currentPlayer = 'human';
    } else {
      _humanSymbol = 'O';
      _computerSymbol = 'X';
      _currentPlayer = 'computer';
      computerMove();
    }
  }

  void humanMove(int cell) {
    if (_currentPlayer != 'human' || _gameOver || _isProcessing) {
      return;
    }
    if (_makeMove(cell)) {
      if (!_gameOver && _currentPlayer == 'computer') {
        computerMove();
      }
    }
  }

  void computerMove() {
    if (_currentPlayer != 'computer' || _gameOver) {
      return;
    }
    lockCells();
    //Future.delayed(Duration(milliseconds: 500));
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == ' ') {
        emptyCells.add(i);
      }
    }
    if (emptyCells.isNotEmpty) {
      int cell = emptyCells[Random().nextInt(emptyCells.length)];
      _makeMove(cell);
    }
    unlockCells();
  }

  bool _makeMove(int cell) {
    // if (cell < 0 || cell > 8 || _board[cell] != ' ') {
    //   return false;
    // }
    // String symbol = _currentPlayer == 'human' ? _humanSymbol : _computerSymbol;
    // _board[cell] = symbol;
    // if (symbol == 'X') {
    //   setX(cell);
    // } else {
    //   setO(cell);
    // }
    // if (_checkWin(symbol)) {
    //   if (_currentPlayer == 'human') {
    //     winProcedure();
    //   } else {
    //     lossProcedure();
    //   }
    //   _gameOver = true;
    // } else if (_checkDraw()) {
    //   lossProcedure();
    //   _gameOver = true;
    // } else {
    //   _switchPlayer();
    // }
    return true;
  }

  void _switchPlayer() {
    //_currentPlayer = _currentPlayer == 'human' ? 'computer' : 'human';
  }

  bool _checkWin(String symbol) {
    // List<List<int>> winningCombos = [
    //   [0, 1, 2], [3, 4, 5], [6, 7, 8], // строки
    //   [0, 3, 6], [1, 4, 7], [2, 5, 8], // столбцы
    //   [0, 4, 8], [2, 4, 6] // диагонали
    // ];
    // for (var combo in winningCombos) {
    //   if (_board[combo[0]] == symbol &&
    //       _board[combo[1]] == symbol &&
    //       _board[combo[2]] == symbol) {
    //     return true;
    //   }
    // }
    return false;
  }

  bool _checkDraw() {
    //return !_board.contains(' ');
    return true;
  }

  void lockCells() {
    _isProcessing = true;
  }

  void unlockCells() {
    _isProcessing = false;
  }

  void setX(int cell) {
    //print('Установлен крестик в ячейке $cell');
  }

  void setO(int cell) {
    //print('Установлен нолик в ячейке $cell');
  }

  void winProcedure() {
    // humanScore++;
    // print(
    //     'Человек победил! Счет: Человек $humanScore - Компьютер $computerScore');
  }

  void lossProcedure() {
    // if (_checkWin(_computerSymbol)) {
    //   computerScore++;
    //   print(
    //       'Компьютер победил! Счет: Человек $humanScore - Компьютер $computerScore');
    // } else {
    //   print('Ничья! Счет: Человек $humanScore - Компьютер $computerScore');
    // }
  }
}
