import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(new DebugAnimationsScreen());

class DebugAnimationsScreen extends StatefulWidget{
  DebugAnimationsScreen({Key key}) : super(key: key);

  @override _DebugState createState() => new _DebugState();
}

class _DebugState extends State<DebugAnimationsScreen> 
    with TickerProviderStateMixin{
  AnimationController controller;
  NewRandomGrid animation;
  List<Widget> squares = new List();

  @override
  void initState(){
    super.initState();

    controller = new AnimationController(vsync: this, 
        duration: const Duration(milliseconds: 600));

    animation = new NewRandomGrid(animationController: controller);

    for(int i = 0; i < 12; i++){
      squares.add(new GestureDetector(
        onTap: _startAnimations,
        child: new Container(
          color: Colors.indigo,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Window Break',
      home: new Scaffold(
        body: new Center(
          child: new AnimatedBuilder(
            animation: animation.transformAnimationController,
            builder: (BuildContext ctx, Widget child) => new Container(
              transform: animation.transformationAnimationTween
                  .evaluate(animation.transformAnimationController),
              child: child,
            ),
            child: new GridView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              physics: new NeverScrollableScrollPhysics(),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.6,
                mainAxisSpacing: 1.6,
              ),
              children: squares,
            ),
          ),
        ),
      ),
    );
  }

  _startAnimations() async {
    await animation.animateDown();
    await animation.animateOut();
    await animation.animateIn();
    await animation.animateUp();
  }
}

class NewRandomGrid {
  AnimationController transformAnimationController;
  Matrix4Tween transformationAnimationTween;

  /// Animation curves
  Curve _gridAnimateUpDownCurve = Curves.decelerate;
  Curve _gridAnimateInOutCurve = Curves.easeInOut;

  /// Animation durations
  Duration gridAnimationUpDownDuration = const Duration(milliseconds: 400);
  Duration gridAnimationInOutDuration = const Duration(milliseconds: 200);

  vector.Vector3 animateOutVector = new vector.Vector3(-400.0, 560.0, 1.0);
  vector.Vector3 animateInVector = new vector.Vector3(550.0, -40.0, 1.0);

  /// Original and animated transformations, can be changed by 
  Matrix4 originalTransformation = new Matrix4.compose(
      new vector.Vector3(1.0, 1.0, 1.0),
      new vector.Quaternion(0.0, 0.0, 0.0, 1.0),
      new vector.Vector3(1.0, 1.0, 1.0));

  Matrix4 animatedTransformation = new Matrix4.compose(
      new vector.Vector3(120.0, 100.0, 1.0),
      new vector.Quaternion(0.0, 0.0, 0.0, 1.0),
      new vector.Vector3(0.45, 0.45, 0.45));

  /// Pass [AnimationController] or [TickerProvider] so class can build it's
  /// own [AnimationController]
  NewRandomGrid({TickerProvider animationSync, 
    AnimationController animationController}){
    assert(animationSync != null || animationController != null);

    transformationAnimationTween = new Matrix4Tween(
        begin: originalTransformation,
        end: animatedTransformation
    );

    transformAnimationController = animationController ?? 
        new AnimationController(
          vsync: animationSync,
          duration: gridAnimationUpDownDuration,
        );
  }

  /// Animate Grid down (Or do some animation but stay in screen boundaries)
  TickerFuture animateDown({List<int> clickedSquares, int correctSquare}){
    // ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼
    // Removing this make animation 'work'
    // ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼
    animatedTransformation = new Matrix4.compose(
        new vector.Vector3(120.0, 100.0, 1.0),
        new vector.Quaternion.random(new Random()),
        new vector.Vector3(0.45, 0.45, 0.45));
    // ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲
    // ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲

    // Set tween to original state
    transformationAnimationTween..begin = originalTransformation;
    transformationAnimationTween..end = animatedTransformation;
    transformAnimationController..duration = gridAnimationUpDownDuration;

    TickerFuture animationFuture = transformAnimationController.animateTo(1.0, 
        curve: _gridAnimateUpDownCurve);

    return animationFuture;
  }

  /// Animate grid out of the screen 
  TickerFuture animateOut(){
    Matrix4 _outMatrix = animatedTransformation.clone();
    _outMatrix.setTranslation(animateOutVector);
    transformationAnimationTween..begin = _outMatrix;
    transformAnimationController..duration = gridAnimationInOutDuration;

    TickerFuture animationFuture = transformAnimationController.animateTo(0.0, 
        curve: _gridAnimateInOutCurve);
    return animationFuture;
  }

  /// Animate grid view back into the screen
  TickerFuture animateIn(){
    /// Matrix is cloned from animated matrix so we can change animated matrix
    /// and rest of animations will work just fine
    Matrix4 _inMatrix = animatedTransformation.clone();
    _inMatrix.setTranslation(animateInVector);
    transformationAnimationTween..begin = _inMatrix;
    transformationAnimationTween..end = animatedTransformation;

    TickerFuture animationFuture = transformAnimationController.animateTo(1.0, 
        curve: _gridAnimateInOutCurve);
    return animationFuture;
  }

  /// Animate grid view back up (or back to [originalTransformation])
  TickerFuture animateUp(){
    transformationAnimationTween..begin = originalTransformation;
    transformAnimationController..duration = gridAnimationUpDownDuration;

    TickerFuture animateFuture = transformAnimationController.animateTo(0.0, 
        curve: _gridAnimateUpDownCurve);
    return animateFuture;
  }
}