import 'package:flutter/material.dart';

class EjRadio extends StatefulWidget {
  const EjRadio({super.key});

    @override
    State <EjRadio>createState() => _EjRadioState();
}

class _EjRadioState extends State<EjRadio> {
  String genero = 'Masculino';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ej: Columnas'),),
      body: Container(
        margin:EdgeInsets.all(10),
        child: Column(
        children: [
          Text("Seleccione"),
          RadioListTile(title: Text('masculino'),
          value: 'Masculino',
          groupValue:genero,
          onChanged:(value){
            setState((){
              genero=value.toString();
            });}
          ),

          RadioListTile(title: Text('femenino'),
          value: 'Femenino',
          groupValue:genero,
          onChanged:(value){
              setState((){
              genero=value.toString();
            });
            }
          ),
        ]
       )
      )
    );
  }
}