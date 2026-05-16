import 'package:flutter/material.dart';

class Cajas1 extends StatefulWidget {
  const Cajas1({super.key});

    @override
    State <Cajas1>createState() => _Cajas1State();
}

class _Cajas1State extends State<Cajas1> {
  bool estado = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  String texto = '';
  String calificacion = '';
  List <String> opciones = ['El señor de los anillos','The amazing Spider-man','Dune'];
  Map<String, String> opc={
    "1":"El señor de los anillos",
    "2":"The amazing Spider-man",
    "3":"Dune"
  };
  bool mostrarError = false;
  String mensajeError = '';
  String? seleccionada;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Peliculas Colombia'),backgroundColor: Colors.grey),
      body: SingleChildScrollView(
      child: Container(
        margin:EdgeInsets.all(10),
        child: Form(
          key:_formKey,
        child: Column(
        children: [
          
  

            Text('Elige tu pelicula favorita',
            style: const TextStyle(fontSize: 18),),
          
      SizedBox(height: 20),

       SizedBox(
            width: 250,
            child:
            DropdownButton<String>(
              isExpanded: true,
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
          ),
        ),
        

        SizedBox(height:40),
        Text('Califica el servicio',
        style: const TextStyle(fontSize: 18),
        ),
        
          SizedBox(
            width: double.infinity,
            child:
            Row(
              children:[
                Expanded(
                  child:
                    RadioListTile(title: Text('1'),
                    value: '1',
                    groupValue:calificacion,
                    onChanged:(value){
                      setState((){
                        calificacion=value.toString();
                      });}
                    ),
                  ),

                Expanded(
                  child:
                    RadioListTile(title: Text('2'),
                    value: '2',
                    groupValue:calificacion,
                    onChanged:(value){
                        setState((){
                        calificacion=value.toString();
                      });
                    }
                  ),
                ),

                Expanded(
                  child:
                    RadioListTile(title: Text('3'),
                    value: '3',
                    groupValue:calificacion,
                    onChanged:(value){
                      setState((){
                        calificacion=value.toString();
                      });}
                    ),
                  ),

                Expanded(
                  child:
                    RadioListTile(title: Text('4'),
                    value: '4',
                    groupValue:calificacion,
                    onChanged:(value){
                        setState((){
                        calificacion=value.toString();
                      });
                    }
                  ),
                ),

                Expanded(
                  child:
                    RadioListTile(title: Text('5'),
                    value: '5',
                    groupValue:calificacion,
                    onChanged:(value){
                        setState((){
                        calificacion=value.toString();
                      });
                    }
                  ),
                ),
              ]
            )
          ),
          
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20,),
            child:Text('Cuentanos, que te gusto y que te gustaria que mejorara del servicio',
            style: const TextStyle(fontSize: 18),
              ),
            ),

           TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingresa tu nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),

          SizedBox(height:30),

          ElevatedButton(
                onPressed: () {
                  setState(() {
                    //validar texto
                      if (!_formKey.currentState!.validate()) return;      
                      //validar calificación
                      if (calificacion.isEmpty) {
                        mostrarError = true;
                        mensajeError = 'selecciona una calificación';
                        return;
                      }
                      mostrarError = false;
                      texto = _controller.text;
                  });
                },
                child: const Text('Enviar'),
              ),

              SizedBox(height:30),
              if (mostrarError)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    mensajeError,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              // Muestra el texto
              Text(
                texto.isEmpty ? '' : 'Nos dices que: $texto',
                style: const TextStyle(fontSize: 18),
              ),

              SizedBox(height:30),

               Text(
                texto.isEmpty ? '' : 'Y le diste una nota a la pelicula de: $calificacion estrellas',
                style: const TextStyle(fontSize: 18),
              ),

        ]
       )
      )
      )
    ),
    );
  }
}