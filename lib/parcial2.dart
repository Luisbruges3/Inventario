import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Parcial2 extends StatefulWidget {
  const Parcial2({super.key});
  
    @override
    State <Parcial2>createState() => _Parcial2State();
}

class _Parcial2State extends State<Parcial2> {
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _borrarController = TextEditingController();
  List <String> opciones = ['Alimentos','Tecnologia','Hogar','Ropa', 'Otros' ];
  Map<String, String> opc={
    "1":"Alimentos",
    "2":"Tecnologia",
    "3":"Hogar", 
    "4":"Ropa",
    "5":"Otros"
  };
  String? seleccionada;
  List<Map<String, String>> productos = [];
  double total = 0.0;

  void guardar(){
    setState((){
      productos.add({
        "referencia": _referenciaController.text,
        "nombre": _nombreController.text,
        "precio": _precioController.text,
        "descripcion": _descripcionController.text,
        "categoria": seleccionada ?? "No seleccionada",
      });
        total += double.tryParse(_precioController.text) ?? 0.0; 

    });

    _referenciaController.clear();
    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();
  }

  void borrar(){
    setState((){
      productos.removeWhere((producto) => producto["referencia"] == _borrarController.text);
      total = productos.fold(0, (sum, p) => sum + (double.tryParse(p["precio"]!) ?? 0.0));
    });

    _borrarController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, 
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hola Usuario", style: TextStyle(fontSize: 35,color:Colors.brown, fontWeight: FontWeight.w600),),
              Text("Agregue sus productos al inventario", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
            ],
          ),
          ],
        ),
      ),

      body: Column(
      children: [
        SizedBox(
                height: MediaQuery.of(context).size.height*0.495,
                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child:Row(
                  children:[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.495,
                      padding: EdgeInsets.all(20),
                      decoration: 
                      BoxDecoration(color: Color.fromARGB(255, 212, 221, 225), borderRadius: BorderRadius.all(Radius.circular(20))),
                    
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:TextFormField(
                                controller: _referenciaController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(labelText: 'Referencia', hintText: 'Ingrese la referencia', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                   return null;
                                },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:TextFormField(
                                controller: _nombreController,
                                decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ingrese el nombre del producto', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                   return null;
                                },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:TextFormField(
                                controller: _precioController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(labelText: 'Precio', hintText: 'Ingrese el precio', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                   return null;
                                },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:TextFormField(
                                controller: _descripcionController,
                                decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Ingrese la descripción', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                   return null;
                                },
                            ),
                          ),

                          Center(child:SizedBox(
                              width: 250,
                              child:DropdownButton<String>(isExpanded: true, value: seleccionada,hint: Text("Seleccione una categoria"),
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
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:
                        Center(child:SizedBox(
                          width: 200,
                         child: ElevatedButton(
                          onPressed:(){guardar();
                        }, child:Text("Agregar Un Producto")
                      ),   
                    )),),

                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child:TextFormField(
                                controller: _borrarController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(labelText: 'Referencia para borrar', hintText: 'Ingrese la referencia para borrar', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                   return null;
                                },
                            ),
                          ),  

                          Center(child:SizedBox(
                          width: 200,
                         child: ElevatedButton(
                          onPressed:(){borrar();
                        }, child:Text("Borrar Un Producto")
                      ),   
                    )),

                    Text("Total: \$${(total).toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ]
                        

                    )
                    ),
                  )
                ],
              ),
            ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color:Color.fromARGB(255, 255, 255, 255),
                  ),
                  padding: EdgeInsets.only(left:20, bottom: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[

                            Text("Inventario Actual", style: TextStyle(fontSize: 30, color: Colors.black),),
                            SizedBox(height: 10,),
                            
                            Expanded(
                            child:ListView( shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              children:productos.map((producto) =>
                                pacientes( producto["nombre"]!, producto["referencia"]!, producto["precio"]!, Colors.white, Colors.black, producto["descripcion"]!, producto["categoria"]!, context),
                              ).toList(), 
                            )
                          ),
                              
                    ]
                  )
                )
              ),
              
            ],
          )
        ),
        

        
        ],
      ),


      
    );

}
   

  Widget pacientes(String titulo, String contenido, String subtitulo, Color color, Color colorTexto, String titulo2,String titulo3,BuildContext context){
    return 
        Container(
          width: MediaQuery.of(context).size.width,
          //height: 141,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children:[
              Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Text(titulo, style: TextStyle(color: colorTexto, fontSize: 20,fontWeight: FontWeight.w700),),
                    Text(contenido, style: TextStyle(color: colorTexto, fontSize: 15, )),
                    Text(subtitulo, style: TextStyle(color: colorTexto, fontSize: 15),)
                  ],
                ),
              ),
            ],
          ),
          
          Row(children: [
          
          
          
          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                  children:[
                    Text(titulo2, style: TextStyle(color: colorTexto, fontSize: 15),),

                  ],
                ),
              ),
              
            ],
          ),
          
          Row(children: [
            

          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children:[
                    Text(titulo3, style: TextStyle(color: colorTexto, fontSize: 15),),
                    Divider(height: 1,color: Colors.grey[350]),
                  ],
                  
                ),
                
              ),

          ])
        ],
      ),
      
    );
  }
}