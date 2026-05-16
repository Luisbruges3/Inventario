import 'package:flutter/material.dart';

class Ejcheck extends StatefulWidget {
  const Ejcheck({super.key});

    @override
    State <Ejcheck>createState() => _EjcheckState();
}

class _EjcheckState extends State<Ejcheck> {
  bool estado = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ej: Columnas'),),
      body: Container(
        margin:EdgeInsets.all(10),
        child: Column(
        children: [
          Text("Seleccione"),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CheckboxListTile(
              value:estado,
              title: Text('Aceptar'),
              onChanged: (value){
                setState((){
                  estado=!estado;
                  }
                );
              }
            )
          ),
        ]
       )
      )
    );
  }
}