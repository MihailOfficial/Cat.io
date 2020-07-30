//nword
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';


const COLOR = const Color(0xff0000ff);
const SIZE = 52.0;
const GRAVITY = 700.0;
const BOOST = -300;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class Cat extends AnimationComponent with Resizable {
  double speedY = 0.0;
  bool frozen;
  Cat()
      : super.sequenced(SIZE*1.5 , SIZE*1.5, 'Running (32 x 32).png', 6,
            textureWidth: 32.0, textureHeight: 32.0) {
    this.anchor = Anchor.center;
    this.frozen = true;
    print("yes");
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
      this.y += speedY * t - GRAVITY * t * t / 2;
      this.speedY += GRAVITY * t;
      this.angle = velocity.angle();
      if (y > size.height || y < 0) {
        reset();
      }
      compx = this.x;
      compy = this.y;
    }
  }

  onTap() {
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
  double speedX = 2.0;
  double posX, posY;

  Coin(double posX, double posY)
      : super.sequenced(SIZE, SIZE, 'coin.png', 1,
            textureWidth: 200.0, textureHeight: 200.0) {
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

    }
    super.update(t);
    this.x -= speedX * 2;
  }
}


class MyGame extends BaseGame {
  var rng;
  Cat cat;

  var coinPattern = [[true, false, true],
                     [false, true, false],
                     [true, false, true]];

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

    add(TextComponent('Score:')

      ..anchor = Anchor.centerRight
      ..x = size.width / 2
      ..y = 32.0);
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


    if(rng.nextInt(1000) < (1000.0/(60.0 * 1.2))){
      double height = rng.nextDouble() * (size.height - 30.0 * coinPattern.length);
      for(var i = 0; i < coinPattern.length; i++){
        for(var j = 0; j < coinPattern[i].length; j++){
          if(coinPattern[j][i]){
            add(new Coin(size.width + j * 30.0, height + i * 30.0));

          }
        }
      }
    }

  }

}
