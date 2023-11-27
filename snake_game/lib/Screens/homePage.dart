import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/Screens/food_pixels.dart';
import 'package:snake_game/Screens/highscore_tile.dart';
import 'package:snake_game/Screens/snake_Pixels.dart';

import 'blank_pixels.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Directions { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // grid dimensions
  int row = 10;
  int totalSquare = 100;
//user score
  int currentScore = 0;

//game settings
  bool gameStarted = false;
  final _nameController = TextEditingController();

  // snake position
  List<int> snakepos = [0, 1, 2];

  // food position
  int foodpos = 55;

  //highscore list
  List<String> highscore_Docs = [];
  late final Future? letsGetDocsIds;

  //snake direction to the initially right
  var currentDirection = snake_Directions.RIGHT;

  @override
  void initState() {
    letsGetDocsIds = getDocId();
    super.initState();
    strtGame();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_Docs.add(element.reference.id);
            }));
  }

  // start game
  void strtGame() {
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        //check if the game is over
        if (gameOver()) {
          timer.cancel();

          //display a message to a user

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Game Over"),
                  content: Column(
                    children: [
                      Text("Your Score is: $currentScore"),
                      TextField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(hintText: 'Enter Name'),
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                      },
                      color: Colors.pink,
                      child: const Text('Submit'),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  Future newGame() async {
    highscore_Docs = [];
    await getDocId();
    snakepos = [0, 1, 2];
    foodpos = 55;
    currentDirection = snake_Directions.RIGHT;
    gameStarted = false;
    currentScore = 0;
  }

  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void eatFoods() {
    currentScore++;
    //making sure the new food is not where the snake is
    while (snakepos.contains(foodpos)) {
      foodpos = Random().nextInt(totalSquare);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Directions.RIGHT:
        {
          // add new head
          //if snake at the right wall, we need to re- adjust
          if (snakepos.last % row == 9) {
            snakepos.add(snakepos.last + 1 - row);
          } else {
            snakepos.add(snakepos.last + 1);
          }
        }
        break;
      case snake_Directions.LEFT:
        {
          // add new head
          //if snake at the right wall, we need to re- adjust
          if (snakepos.last % row == 0) {
            snakepos.add(snakepos.last - 1 + row);
          } else {
            snakepos.add(snakepos.last - 1);
          }
        }
        break;
      case snake_Directions.UP:
        {
          // add new head
          if (snakepos.last < row) {
            snakepos.add(snakepos.last - row + totalSquare);
          } else {
            snakepos.add(snakepos.last - row);
          }
        }
        break;
      case snake_Directions.DOWN:
        {
          // add new head
          if (snakepos.last + row > totalSquare) {
            snakepos.add(snakepos.last + row - totalSquare);
          } else {
            snakepos.add(snakepos.last + row);
          }
        }
        break;

      default:
    }
    if (snakepos.last == foodpos) {
      //snkae eating the food
      eatFoods();
    } else {
      // remove the tail
      snakepos.removeAt(0);
    }
  }

  // game over
  bool gameOver() {
    //the game is over when the snake is run into itself
    //this occur when there is duplicate position in the snakepos list

    //this list is the body of the snake(no -head )
    List<int> bodySnake = snakepos.sublist(0, snakepos.length - 1);

    if (bodySnake.contains(snakepos.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Directions.UP) {
            currentDirection = snake_Directions.DOWN;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Directions.DOWN) {
            currentDirection = snake_Directions.UP;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Directions.RIGHT) {
            currentDirection = snake_Directions.LEFT;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Directions.LEFT) {
            currentDirection = snake_Directions.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              // scores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //user current Score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Curent Score'),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(fontSize: 36),
                          ),
                        ],
                      ),
                    ),
                    //highScore , top 5 or 10
                    Expanded(
                      child: gameStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocsIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: highscore_Docs.length,
                                  itemBuilder: ((context, index) {
                                    return HighScoreTile(
                                        documentId: highscore_Docs[index]);
                                  }),
                                );
                              }),
                    )
                  ],
                ),
              ),

              // grid
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_Directions.UP) {
                      currentDirection = snake_Directions.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_Directions.DOWN) {
                      currentDirection = snake_Directions.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_Directions.LEFT) {
                      currentDirection = snake_Directions.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_Directions.RIGHT) {
                      currentDirection = snake_Directions.LEFT;
                    }
                  },
                  child: GridView.builder(
                    itemCount: totalSquare,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: row,
                    ),
                    itemBuilder: (context, index) {
                      if (snakepos.contains(index)) {
                        return const SnakePixels();
                      } else if (foodpos == index) {
                        return const FoodPixels();
                      } else {
                        return const BlankPixels();
                      }
                    },
                  ),
                ),
              ),

              // button
              Expanded(
                child: Center(
                  child: MaterialButton(
                    color: gameStarted ? Colors.grey : Colors.pink,
                    onPressed: gameStarted ? () {} : strtGame,
                    child: const Text("Play"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
