import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/flame.dart';
const COLOR = const Color(0xff0000ff);
const SIZE = 52.0;
const GRAVITY = 400.0;
const BOOST = -380;

void main() async {
WidgetsFlutterBinding.ensureInitialized();
final size = await Flame.util.initialDimensions();
final game = MyGame(size);
runApp(game.widget);

}

class Bg extends Component with Resizable {
  static final Paint _paint = Paint()
    ..color = COLOR;

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), _paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}

class Cat extends AnimationComponent with Resizable {
  double speedY = 0.0;
  bool frozen;
  Cat() : super.sequenced(
      SIZE, SIZE, 'cat.png', 4, textureWidth: 16.0, textureHeight: 16.0) {
    this.anchor = Anchor.center;
  }

  Position get velocity => Position(300.0, speedY);
  reset(){
    this.x = size.width / 2;
    this.y = size.height / 2;
    speedY = 0;
    angle = 0.0;
  }



  @override
  void resize(Size size) {
    super.resize(size);
    reset();
    frozen = true;
  }
  @override
  void update (double t){
    super.update(t);
    if (frozen) return;
    this.y += speedY * t - GRAVITY*t*t/2;
    this.speedY += GRAVITY * t;
    this.angle = velocity.angle();
    if (y > size.height){
      reset();
    }
  }
  onTap(){
    if (frozen){
      frozen = false;
      return;
    }
    speedY = (speedY + BOOST).clamp(BOOST, speedY);
  }
}

class MyGame extends BaseGame {
  Cat cat;
  MyGame(Size size){
    add(Bg());
    add(cat = Cat());
  }
  @override
  void onTap(){
    cat.onTap();
  }
}



