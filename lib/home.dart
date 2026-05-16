import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

    @override
    State <Home>createState() => _HomeState();
}
     
class _HomeState extends State<Home> {
  List <String> opciones = ['opcion 1','opcion 2','opcion 3'];
  

  Map<String, String> opc={
    "1":"Opcion1",
    "2":"Opcion2",
    "3":"Opcion3"
  };

  String? seleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ej: Columnas'),),
      body: Center(
        child: 
        DropdownButton<String>(
          value: seleccionada,
          hint: Text("Selecciona una opcion"),
          items: opciones.map((String value){
            return DropdownMenuItem(
              value: value,
              child: Text(value)
            );
            }).toList(),
            onChanged: (String? newValue){
              setState((){
                seleccionada = newValue;
              });
            },
        )
      )
    );
  }
}


/*  DropdownButton<String>(
            value: seleccionada, 
            onChanged: (String? value){
              setState(() {
                seleccionada = value;
              });
            },
            items: opc.entries.map((e){
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            ),
*/