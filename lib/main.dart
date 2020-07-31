//nword
import 'dart:io';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import "package:normal/normal.dart";
import "package:flame/time.dart";

const COLOR = const Color(0xff0000ff);
const SIZE = 52.0;
const GRAVITY = 700.0;
const BOOST = -300;
var score = 0;
bool updateScore = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  final size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class Bg extends Component with Resizable {
  static final Paint _paint = Paint()..color = COLOR;

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, 50, 50), _paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}
String message;
bool specialMessage = false;
bool eliminateScoreFlash = false;
class Cat extends AnimationComponent with Resizable {
  double speedY = 0.0;
  bool frozen;
  Cat()
      : super.sequenced(SIZE*1.5 , SIZE*1.5, 'Running (32 x 32).png', 6,
      textureWidth: 32.0, textureHeight: 32.0) {
    this.anchor = Anchor.center;
    this.frozen = true;
    specialMessage = true;
    message = "Tap anywhere!";
    updateScore = true;
    eliminateScoreFlash = true;
  }

  Position get velocity => Position(300.0, speedY);





  reset() {
    this.x = size.width / 2;
    this.y = size.height / 2;
    speedY = 0;
    angle = 0.0;
    frozen = true;

  }

  @override
  void resize(Size size) {
    super.resize(size);
    reset();
    frozen = true;
  }


  @override
  void update(double t) {
    super.update(t);
    if (!frozen) {
      this.y += speedY * t; // - GRAVITY * t * t / 2
      this.speedY += GRAVITY * t;
      this.angle = velocity.angle();
      if (y > size.height || y < 0) {
        specialMessage = true;
        message = "You died!";
        updateScore = true;
        score = 0;
        reset();
      }
      compx = this.x;
      compy = this.y;
    }
  }

  onTap() {
    specialMessage = false;
    updateScore = true;
    if (frozen) {
      frozen = false;
      return;
    }
    speedY = speedY + BOOST;
    //speedY = -300;
  }
}
double compx = 0.0;
double compy = 0.0;
double printer = 0.0;

class Coin extends AnimationComponent with Resizable {
  double speedX = 200.0;
  double posX, posY;

  Coin(double posX, double posY)
      : super.sequenced(SIZE/1.4, SIZE/1.4, 'cointrial.png', 8,
      textureWidth: 52.5, textureHeight: 54) {
    this.anchor = Anchor.center;
    this.x = posX;
    this.y = posY;
  }
  reset() {
    this.x = size.width;

    angle = 0.0;
  }

  @override
  void update(double t) {
    if (x < 0) {
      destroy();
    }
    double dist = sqrt((compy-y)*(compy-y) + (compx-x)*(compx-x));

    if (dist < 45) {
      this.x = -200000;
      this.y = -200000;
      score++;
      updateScore = true;
      return;
    }
    super.update(t);
    this.x -= speedX * t;
  }
}

class MyGame extends BaseGame {
  var rng;
  Cat cat;
  double timer;
  List coinPatterns = [];
  TextPainter textPainter;
  Offset position;

  var coinPattern1 = [[1, 0, 1],
    [0, 1, 0],
    [1, 0, 1]];
  var coinPattern2 = [[1, 0, 0],
    [0, 1, 0],
    [0, 0, 1]];
  var coinPattern3 = [[0, 1, 0],
    [1, 0, 1],
    [0, 1, 0]];
  var coinPattern4 = [[1, 1, 1, 1, 1, 1]];
  var coinPattern5 = [[0, 0, 1],
    [0, 1, 0],
    [1, 0, 0]];

  static List<ParallaxImage> images = [

    ParallaxImage("bg-clouds.png"),
    ParallaxImage("bg-mountains.png"),
    ParallaxImage("bg-trees.png"),


  ];
  final parallaxComponent = ParallaxComponent(images,
      baseSpeed: const Offset(20, 0), layerDelta: const Offset(30, 0));

  MyGame(Size size) {
    add(parallaxComponent);
    add(cat = Cat());
    this.rng = new Random();
    this.timer = Normal.quantile(rng.nextDouble(), mean: 2, variance: 0.5);
    coinPatterns.add(coinPattern1);
    coinPatterns.add(coinPattern2);
    coinPatterns.add(coinPattern3);
    coinPatterns.add(coinPattern4);
    coinPatterns.add(coinPattern5);
    textPainter = TextPainter(text: TextSpan(text: "Score: " + score.toString(), style: TextStyle(color: Colors.white, fontFamily: "pixelFont", fontSize: 32)), textDirection: TextDirection.ltr);
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    position = Offset(size.width / 2 - textPainter.width / 2, size.height * 0.05 - textPainter.height / 2);
  }
  @override
  void onTapDown(TapDownDetails details) {
    cat.onTap();
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }

  void update(double t) {
    super.update(t);

    timer -= t;
    if (timer < 0) {
      timer = Normal.quantile(rng.nextDouble(), mean: 0, variance: 3) + 4.0;
      int pattern = rng.nextInt(coinPatterns.length);
      print(pattern);
      var coinPattern = coinPatterns[pattern];
      double patternHeight = rng.nextDouble() * (size.height - 30.0 * coinPattern.length - 10.0);

      for (var i = 0; i < coinPattern.length; i++) {
        for (var j = 0; j < coinPattern[i].length; j++) {
          if (coinPattern[i][j] == 1) {
            add(new Coin(
                size.width + j * 30.0 + 10, patternHeight + i * 30.0 + 10));
          }
        }
      }
    }

    if(updateScore) {
      if (specialMessage) {
        textPainter = TextPainter(text: TextSpan(
            text: message,
            style: TextStyle(
                color: Colors.white, fontFamily: "pixelFont", fontSize: 32)),
            textDirection: TextDirection.ltr);
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        position = Offset(size.width / 2 - textPainter.width / 2,
            size.height * 0.05 - textPainter.height / 2);
        updateScore = false;
      }
      else if (eliminateScoreFlash){
        textPainter = TextPainter(text: TextSpan(
            text: "Score: " + score.toString(),
            style: TextStyle(
                color: Colors.white, fontFamily: "pixelFont", fontSize: 32)),
            textDirection: TextDirection.ltr);
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        position = Offset(size.width / 2 - textPainter.width / 2,
            size.height * 0.05 - textPainter.height / 2);
        updateScore = false;
      }
      }
    }


  @override
  void render(Canvas c){
    super.render(c);
    textPainter.paint(c, position);
  }

}