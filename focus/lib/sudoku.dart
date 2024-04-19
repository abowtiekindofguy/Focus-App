import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'update_game.dart';
import 'package:flutter/services.dart';
import 'firebase_map.dart';

class Sudoku {
  late List<List<int>> mat;
  List<List<int>> sol = List.generate(9, (index) => List.filled(9, 0));
  late int n;
  late int srn;
  late int k;

  Sudoku(int n, int k) {
    this.n = n;
    this.k = k;

    double srnd = sqrt(n.toDouble());
    srn = srnd.toInt();
    mat = List.generate(n, (index) => List.filled(n, 0));
  }

  void fillValues() {
    fillDiagonal();
    fillRemaining(0, srn);
    printSudoku();
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        sol[i][j] = mat[i][j];
      }
    }
    removeKDigits();
  }

  void fillDiagonal() {
    for (int i = 0; i < n; i += srn) {
      fillBox(i, i);
    }
  }

  bool unUsedInBox(int rowStart, int colStart, int num) {
    for (int i = 0; i < srn; i++) {
      for (int j = 0; j < srn; j++) {
        if (mat[rowStart + i][colStart + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  void fillBox(int row, int col) {
    int num;
    for (int i = 0; i < srn; i++) {
      for (int j = 0; j < srn; j++) {
        do {
          num = randomGenerator(n);
        } while (!unUsedInBox(row, col, num));
        mat[row + i][col + j] = num;
      }
    }
  }

  int randomGenerator(int num) {
    return Random().nextInt(num) + 1;
  }

  bool checkIfSafe(int i, int j, int num) {
    return (unUsedInRow(i, num) &&
        unUsedInCol(j, num) &&
        unUsedInBox(i - i % srn, j - j % srn, num));
  }

  bool unUsedInRow(int i, int num) {
    for (int j = 0; j < n; j++) {
      if (mat[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool unUsedInCol(int j, int num) {
    for (int i = 0; i < n; i++) {
      if (mat[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool fillRemaining(int i, int j) {
    if (j >= n && i < n - 1) {
      i = i + 1;
      j = 0;
    }
    if (i >= n && j >= n) {
      return true;
    }
    if (i < srn) {
      if (j < srn) {
        j = srn;
      }
    } else if (i < n - srn) {
      if (j == (i ~/ srn) * srn) {
        j = j + srn;
      }
    } else {
      if (j == n - srn) {
        i = i + 1;
        j = 0;
        if (i >= n) {
          return true;
        }
      }
    }
    for (int num = 1; num <= n; num++) {
      if (checkIfSafe(i, j, num)) {
        mat[i][j] = num;
        if (fillRemaining(i, j + 1)) {
          return true;
        }
        mat[i][j] = 0;
      }
    }
    return false;
  }

  void removeKDigits() {
    int count = k;
    while (count != 0) {
      int cellId = randomGenerator(n * n) - 1;
      int i = (cellId ~/ n);
      int j = cellId % n;
      if (j != 0) {
        j = j - 1;
      }
      if (mat[i][j] != 0) {
        count--;
        mat[i][j] = 0;
      }
    }
  }

  void printSudoku() {
    String str_mat = '';
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        str_mat += '${mat[i][j]} ';
      }
      str_mat += '\n';
    }
    print(str_mat);
  }
}

class SudokuGame {
  Sudoku sudoku = Sudoku(9, 30);
  List<List<int>> board = List.generate(9, (index) => List.filled(9, 0));

  SudokuGame() {
    this.sudoku.fillValues();
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        board[i][j] = (sudoku.mat[i][j] != 0) ? sudoku.mat[i][j] : 1;
      }
    }
  }

  void setCellValue(int row, int col, int value) {
    board[row][col] = value;
  }

  void incrementCellValue(int row, int col) {
    board[row][col] = (board[row][col] % 9) + 1;
  }

  bool checkSudoku({method = false}) {
    if (method) {
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (board[i][j] != sudoku.sol[i][j]) {
            return false;
          }
        }
      }
      return true;
    } else {
      for (int i = 0; i < 9; i++) {
        Set<int> row = Set<int>();
        row.add(0);
        for (int j = 0; j < 9; j++) {
          if (row.contains(board[i][j])) {
            return false;
          }
          row.add(board[i][j]);
        }
      }
      for (int i = 0; i < 9; i++) {
        Set<int> col = Set<int>();
        col.add(0);
        for (int j = 0; j < 9; j++) {
          if (col.contains(board[j][i])) {
            return false;
          }
          col.add(board[j][i]);
        }
      }
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          Set<int> box = Set<int>();
          box.add(0);
          for (int k = 0; k < 3; k++) {
            for (int l = 0; l < 3; l++) {
              if (box.contains(board[i * 3 + k][j * 3 + l])) {
                return false;
              }
              box.add(board[i * 3 + k][j * 3 + l]);
            }
          }
        }
      }
      return true;
    }
  }
}

class SudokuPage extends StatefulWidget {
  final String currentUserId;
  SudokuPage({required this.currentUserId});

  @override
  _SudokuPageState createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  SudokuGame _sudokuGame = SudokuGame();
  int _seconds = 0;
  late Timer _timer;
  int _row = 0;
  int _col = 0;
  bool _res = false;
  bool _load = false;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedSeconds = prefs.getInt('seconds');
    if (savedSeconds != null) {
      setState(() {
        _seconds = savedSeconds;
      });
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seconds', _seconds);
  }

  void _async_reset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _seconds = 0;
    _sudokuGame = SudokuGame();
    prefs.remove('seconds');
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        prefs.remove('board' + i.toString() + j.toString());
        prefs.remove('mat' + i.toString() + j.toString());
      }
    }
  }

  void _startTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds = (prefs.getInt('seconds') ?? 0) + 1;
        prefs.setInt('seconds', _seconds);
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            if (!_res) {
              _sudokuGame.board[i][j] =
                  prefs.getInt('board' + i.toString() + j.toString()) ??
                      _sudokuGame.board[i][j];
              _sudokuGame.sudoku.mat[i][j] =
                  prefs.getInt('mat' + i.toString() + j.toString()) ??
                      _sudokuGame.sudoku.mat[i][j];
            }
            prefs.setInt(
                'board' + i.toString() + j.toString(), _sudokuGame.board[i][j]);
            prefs.setInt('mat' + i.toString() + j.toString(),
                _sudokuGame.sudoku.mat[i][j]);
          }
        }
        _load = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255,18,18,18),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        title: const Text('Sudoku Game'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(9, (row) {
                    return Row(
                      children: List.generate(9, (col) {
                        if (_sudokuGame.sudoku.mat[row][col] == 0) {}
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_sudokuGame.sudoku.mat[row][col] == 0) {
                                _row = row;
                                _col = col;
                              }
                            });
                          },
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.black, width: (row == 0) ? 5 : 1),
                                  left: BorderSide(
                                      color: Colors.black, width: (col == 0) ? 5 : 1),
                                  right: BorderSide(
                                      color: Colors.black,
                                      width:
                                          (col % 3 == 2) ? ((col == 8) ? 5 : 4) : 1),
                                  bottom: BorderSide(
                                      color: Colors.black,
                                      width:
                                          (row % 3 == 2) ? ((row == 8) ? 5 : 4) : 1),
                                ),
                                color:
                                    (_sudokuGame.sudoku.mat[row][col] == 0 && _load)
                                        ? ((row == _row && col == _col)
                                            ? const Color.fromARGB(255, 207, 64, 233)
                                            : Colors.white)
                                        : Colors.grey[350],
                              ),
                              child: Center(
                                child: Text(
                                  (_load)
                                      ? _sudokuGame.board[row][col].toString()
                                      : "0",
                                  style: (_sudokuGame.sudoku.mat[row][col] == 0)
                                      ? TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold)
                                      : TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int number = index + 1;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: FloatingActionButton(
                            onPressed: () {
                              _sudokuGame.board[_row][_col] = number;
                              _res = true;
                            },
                            child: Container(
                              child: Center(
                                child: Text(
                                  number.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(4, (index) {
                      int number = index + 6;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: FloatingActionButton(
                            onPressed: () {
                              _sudokuGame.board[_row][_col] = number;
                              _res = true;
                            },
                            child: Container(
                              child: Center(
                                child: Text(
                                  number.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _async_reset();
                    _res = true;
                  },
                  child: Text('New Game'),
                  style: ElevatedButton.styleFrom(
                  ),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      bool isValid = _sudokuGame.checkSudoku();
                      if (isValid) {
                        int _score = 10000 ~/ _seconds;
                        DateTime todayDate = DateTime.now();
                        String dateSlug = todayDate.year.toString() +
                            '-' +
                            todayDate.month.toString() +
                            '-' +
                            todayDate.day.toString();
                        setFirebaseValue(widget.currentUserId, 'sudokuGameScore', 'score', _score);
                        setFirebaseValue(widget.currentUserId, 'sudokuGameScore', 'date', dateSlug);
                        // GameStatistics().setGameScore(
                        //     'sudokuGame', widget.currentUserId, _score);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Victory'),
                              content: Text(
                                  'Congratulations! You solved the Sudoku puzzle. \n' + 'Time taken: ${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}' + '\n' + 'Score: $_score'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _async_reset();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        
                      } else {
                        // Board is not valid
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Fail'),
                              content: Text(
                                  'Sorry! The Sudoku puzzle is not solved correctly.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                  },
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
