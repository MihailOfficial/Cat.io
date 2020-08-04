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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import "package:normal/normal.dart";
import "package:flame/time.dart";
import 'package:shared_preferences/shared_preferences.dart';

const COLOR = const Color(0xff0000ff);
const SIZE = 52.0;
const GRAVITY = 700.0;
const BOOST = -300;
var score = 0;
bool updateScore = false;
int highScore = 0;
int gemCollected = -1;
MyGame game;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //SharedPreferences storage = await SharedPreferences.getInstance();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  final size = await Flame.util.initialDimensions();
  game = MyGame(size);

  runApp(game.widget);
  TapGestureRecognizer tapper = TapGestureRecognizer();
  tapper.onTapDown = game.onTapDown;
  flameUtil.addGestureRecognizer(tapper);
}

class Bg extends Component with Resizable {
  static final Paint _paint = Paint()..color = COLOR;

  @override
  void render(Canvas c) {


  }

  @override
  void update(double t) {
    // TODO: implement update
  }

}
String message;
bool specialMessage = false;
bool eliminateScoreFlash = false;
bool spikeDeath = false;
bool frozen = true;
class CharacterSprite extends AnimationComponent with Resizable {
  double speedY = 0.0;

  CharacterSprite()
      : super.sequenced(SIZE*1.5 , SIZE*1.5, 'Running (32 x 32).png', 6,
      textureWidth: 32.0, textureHeight: 32.0) {
    this.anchor = Anchor.center;
    frozen = true;
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
        updatehighScore = true;
        reset();
      }
      if (spikeDeath){
        updatehighScore = true;
        reset();
      }
      compx = this.x;
      compy = this.y;
    }
  }

  onTap() {
    paused = false;
    specialMessage = false;
    updateScore = true;
    updatehighScore = true;
    spikeDeath = false;
    if (frozen) {
      frozen = false;
      return;
    }
    if (!paused) {
      speedY = speedY + BOOST;
      //speedY = -300;
    }
  }
}
double compx = 0.0;
double compy = 0.0;
double printer = 0.0;
bool collected = false;
double collectedX;
double collectedY;
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


  @override
  void update(double t) {
    if (frozen){
      this.x = -200000;
    }
    if (x < 0) {
      destroy();
    }
    double dist = sqrt((compy-y)*(compy-y) + (compx-x)*(compx-x));

    if (dist < 45 || gemCollected == 0) {
      collected = true;
      collectedX = this.x;
      collectedY = this.y;
      game.add(new coinCollected(this.x, this.y));
      this.x = -200000;
      this.y = -200000;
      score++;
      if (score > highScore){
        highScore = score;
      }
      updatehighScore = true;
      updateScore = true;
      return;
    }
    super.update(t);
    if (!paused) {
      this.x -= speedX * t;
    }
  }
}

class Spike extends AnimationComponent with Resizable {
  double speedX = 200.0;
  double posX = 0;
  double posY;

  Spike(double posX, double posY)
      : super.sequenced(SIZE, SIZE, 'Spike.png', 8,
      textureWidth: 38, textureHeight: 38) {
    this.anchor = Anchor.center;
    this.x = posX;
    this.y = posY;
  }


  @override
  void update(double t) {
    if (frozen){
      this.x = -200000;
    }
    if (x < 0 ) {
      destroy();
    }
    double dist = sqrt((compy-y)*(compy-y) + (compx-x)*(compx-x));

    if (dist < 45) {
      this.x = -200000;
      this.y = -200000;
      score=0;
      specialMessage = true;
      message ="Sliced!";
      updateScore = true;
      spikeDeath = true;

      return;
    }
    super.update(t);

      this.x -= speedX * t;

  }
}
class Gem extends AnimationComponent with Resizable {
  double speedX = 200.0;
  double posX = 0;
  double posY;

  Gem(double posX, double posY)
      : super.sequenced(SIZE/1.3, SIZE/1.3, 'gemIcon.png', 4,
      textureWidth: 16, textureHeight: 16) {
    this.anchor = Anchor.center;
    this.x = posX;
    this.y = posY;
  }

  @override
  void update(double t) {
    if (frozen){
      this.x = -200000;
    }
    if (x < 0) {
      destroy();
    }
    double dist = sqrt((compy-y)*(compy-y) + (compx-x)*(compx-x));

    if (dist < 45) {
      this.x = -200000;
      this.y = -200000;

      updateScore = true;
      gemCollected = 1;
      return;
    }
    super.update(t);

      this.x -= speedX * t;

  }
}
bool paused = false;
double height = 0;
double width = 0;
double heighttemp = 0;
double widthtemp = 0;
double heighttemp1 = 0;
double widthtemp1 = 0;
class PauseButton extends AnimationComponent with Resizable {

  Rect pauseRect;
  PauseButton()
      : super.sequenced(SIZE / 1.3, SIZE / 1.3, 'pause.png', 1,
      textureWidth: 14, textureHeight: 14) {
    place();
    this.anchor = Anchor.center;


  }
  void place(){
    this.x = width;
    this.y = height;


    pauseRect = Rect.fromLTWH(widthtemp,  heighttemp, 40,40);

  }
  void onTapDown() {
    print("test");
    paused = true;
  }
  void resize(Size size) {
    super.resize(size);
    height = size.height-50;
    width = size.width/2;
    heighttemp = size.height-70;
    widthtemp = (size.width/2)-20;

    place();
  }
}


class coinCollected extends AnimationComponent with Resizable {
  double speedX = 200.0;
  double posX = 0;
  double posY;
  double timeLeft = 0.1;

  coinCollected(double posX, double posY)
      : super.sequenced(SIZE, SIZE, 'Collected.png', 6,
      textureWidth: 32, textureHeight: 32) {
    this.anchor = Anchor.center;
    this.x = posX;
    this.y = posY;
    this.destroyOnFinish = true;
  }


  @override
  void update(double t) {
    /*
    if (timeLeft < 0) {
      print("destroy");
      this.destroy();
    } else {
      timeLeft -= t;
    }
    double dist = sqrt((collectedY-y)*(collectedY-y) + (collectedX-x)*(collectedX-x));
    if (dist>90){
      this.x = 2000;
    }
    */
    super.update(t);
    this.x -= speedX * t;
  }
}
bool updatehighScore = false;
class MyGame extends BaseGame {
  var rng;
  CharacterSprite character;
  double timerCharacter;
  double timerSpike;
  double timerGem;
  List coinPatterns = [];
  TextPainter textPainterScore;
  TextPainter textPainterHighScore;
  Offset positionScore;
  Offset positionHighScore;
  PauseButton pauseButton;
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
    add(character = CharacterSprite());


    this.rng = new Random();
    this.timerCharacter = Normal.quantile(rng.nextDouble(), mean: 2, variance: 0.5);
    this.timerSpike = Normal.quantile(rng.nextDouble(), mean: 2, variance: 0.5);
    this.timerGem = Normal.quantile(rng.nextDouble(), mean: 3, variance: 0.7);
    coinPatterns.add(coinPattern1);
    coinPatterns.add(coinPattern2);
    coinPatterns.add(coinPattern3);
    coinPatterns.add(coinPattern4);
    coinPatterns.add(coinPattern5);

    textPainterScore = TextPainter(text: TextSpan(
        text: "Score: " + score.toString(),
        style: TextStyle(
            color: Colors.white, fontFamily: "pixelFont", fontSize: 32)),
        textDirection: TextDirection.ltr);
    textPainterScore.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    positionScore = Offset(size.width / 2 - textPainterScore.width / 2,
        size.height * 0.020 - textPainterScore.height / 2);
    textPainterHighScore = TextPainter(text: TextSpan(
        text: "Highest:" + score.toString(),
        style: TextStyle(
            color: Colors.yellow, fontFamily: "pixelFont", fontSize: 20)),
        textDirection: TextDirection.ltr);
    textPainterHighScore.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    positionHighScore = Offset(size.width / 2 - textPainterHighScore.width / 2,
        size.height * 08 - textPainterHighScore.height / 2);
  }

  @override
  void onTapDown(TapDownDetails d) {
    character.onTap();

    if (pauseButton.pauseRect.contains(d.globalPosition)){
    pauseButton.onTapDown();
    }
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }

  void update(double t) {
  if(!paused) {
    super.update(t);
  }

    if (gemCollected >= 0) {
      gemCollected--;
    }
    if (!frozen && !paused) {

      timerCharacter -= t;
      timerSpike -= t;
      timerGem -= t;
      if (timerGem < 0) {
        double posGem = rng.nextDouble() * size.height;
        add(new Gem(size.width, posGem));

        timerGem = Normal.quantile(rng.nextDouble(), mean: 0, variance: 0.7) + 2;
      }
      if (timerSpike < 0) {
        double posCharacter = rng.nextDouble() * size.height;
        add(new Spike(size.width, posCharacter));

        timerSpike = Normal.quantile(rng.nextDouble(), mean: 0, variance: 0.3) + 1;
      }
      if (timerCharacter  < 0) {
        timerCharacter =
            Normal.quantile(rng.nextDouble(), mean: 0, variance: 0.15) + 0.5;
        int pattern = rng.nextInt(coinPatterns.length);

        var coinPattern = coinPatterns[pattern];
        double patternHeight = rng.nextDouble() *
            (size.height - 30.0 * coinPattern.length - 10.0);

        for (var i = 0; i < coinPattern.length; i++) {
          for (var j = 0; j < coinPattern[i].length; j++) {
            if (coinPattern[i][j] == 1) {
              add(new Coin(
                  size.width + j * 30.0 + 10, patternHeight + i * 30.0 + 10));
            }
          }
        }
      }
    }


      if (updateScore) {
        if (specialMessage) {
          textPainterScore = TextPainter(text: TextSpan(
              text: message,
              style: TextStyle(
                  color: Colors.white, fontFamily: "pixelFont", fontSize: 32)),
              textDirection: TextDirection.ltr);
          textPainterScore.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          positionScore = Offset(size.width / 2 - textPainterScore.width / 2,
              size.height * 0.05 - textPainterScore.height / 2);
          updateScore = false;
        }
        else if (eliminateScoreFlash) {
          textPainterScore = TextPainter(text: TextSpan(
              text: "Score: " + score.toString(),
              style: TextStyle(
                  color: Colors.white, fontFamily: "pixelFont", fontSize: 32)),
              textDirection: TextDirection.ltr);
          textPainterScore.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          positionScore = Offset(size.width / 2 - textPainterScore.width / 2,
              size.height * 0.05 - textPainterScore.height / 2);
          updateScore = false;
        }
      }
      else if (updatehighScore) {
        textPainterHighScore = TextPainter(text: TextSpan(
            text: "Highest: " + highScore.toString(),
            style: TextStyle(
                color: Colors.yellow, fontFamily: "pixelFont", fontSize: 20)),
            textDirection: TextDirection.ltr);
        textPainterHighScore.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        positionHighScore =
            Offset(size.width / 2 - textPainterHighScore.width / 2,
                size.height * 0.08 - textPainterHighScore.height / 2);
        updatehighScore = false;
      }

    add(pauseButton = PauseButton());
    }


    @override
    void render(Canvas c) {
      super.render(c);
      textPainterScore.paint(c, positionScore);
      textPainterHighScore.paint(c, positionHighScore);
    }

  }

