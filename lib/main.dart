import 'package:flutter/material.dart';
import 'container.dart';
import 'doctor.dart';
import 'home.dart';
import 'CustomTextField.dart';
import 'cajas2.dart';
import 'radio.dart';
import 'cajas1.dart';
import 'cajas3.dart';
import 'ejCheck.dart';
import 'parcial2.dart';
import 'dbFront.dart';
import 'databaseHelper.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.initDb();
  await DatabaseHelper.instance.initializeUsers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    @override
    Widget build(BuildContext context) {  

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      home: const UserList(),
    );
  }
}

class figuras extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint= Paint()
    ..color=Colors.red
    //..style=PaintingStyle.stroke
    ..strokeWidth=15;

    var path = Path();
    //triangulo
    //path.lineTo(0,200);
    //path.lineTo(200,200);
    //path.lineTo(0,0);

    //cuadrado
    //path.lineTo(0,200);
    //path.lineTo(200,200);
    //path.lineTo(200,0);
    //path.lineTo(0,0);

    //triangulo
    //path.moveTo(size.width*0.5, 0);
    //path.lineTo(0,200);
    //path.lineTo(size.width,200);
    //path.lineTo(size.width*0.5, 0);

    //rombo
    //path.moveTo(size.width*0.5, 0);
    //path.lineTo(0, 200);
    //path.lineTo(size.width*0.5, 400);
    //path.lineTo(size.width, 200);
    //path.lineTo(size.width*0.5, 0);

    //triangulo con curvas
    path.moveTo(size.width*0.5, 0);
    path.quadraticBezierTo(size.width*0.5, size.height*0.25, 0, size.height*0.5);
    path.quadraticBezierTo(size.width*0.5, size.height*0.25, size.width, size.height*0.5);
    path.quadraticBezierTo(size.width*0.5, size.height*0.25, size.width*0.5, 0);

    //curvas
    //path.lineTo(0, size.width*0.5);
    //path.quadraticBezierTo(size.width*0.25, size.height*0.25, size.width*0.5, size.height*0.5);
    //path.quadraticBezierTo(size.width*0.75, size.height*0.75, size.width, size.height*0.5);
    //path.lineTo(size.width, 0);
    //path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




class Pantalla1 extends StatelessWidget {
  const Pantalla1({super.key});
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top:100,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child:CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                painter: figuras(),
              ),
            ),
          )
        ],
      ),
    );
  }
}