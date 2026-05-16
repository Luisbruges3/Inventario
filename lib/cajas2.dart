import 'package:flutter/material.dart';
import 'dart:math';
import 'CustomTextField.dart';

class Cajas2 extends StatefulWidget {
  const Cajas2({super.key});

    @override
    State <Cajas2>createState() => _CajasState();
}

class _CajasState extends State<Cajas2> {
  TextEditingController cntAltura = TextEditingController();
  TextEditingController cntRadio = TextEditingController();
  int? aLateral;
  int? aTotal;
  int? volumen;

  void calcularTotal(){
    int altura = int.parse(cntAltura.text);
    int radio = int.parse(cntRadio.text);
    setState((){
      aLateral=(2*pi*altura*radio).toInt();
      aTotal=(2*pi*radio*(altura+radio)).toInt();
      volumen=(pi*pow(radio,2)*altura).toInt();}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ej: Columnas'),),
      body: Column(children: [
          /*TextField(
            controller: cntAltura,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Digite altura del cilindro",
              border: OutlineInputBorder()
              )
          ),*/
          CustomTextField(placeholder:"Digite altura del cilindro",
                          cnt: cntAltura,
                          typeKeyboard: TextInputType.number,),
          SizedBox(height:10),
          /*TextField(
            controller: cntRadio,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Digite radio del cilindro",
              border: OutlineInputBorder()
              )
          ),*/
          CustomTextField(placeholder:"Digite radio del cilindro",
                          cnt: cntRadio,
                          typeKeyboard: TextInputType.number,),

          ElevatedButton(
              onPressed:(){calcularTotal();
            }, child:Text("Calcular")
          ),

          Text("$aLateral"),
          Text("$aTotal"),
          Text("$volumen")
        ]
      )
    );
  }

}

