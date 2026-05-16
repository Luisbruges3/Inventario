import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'databaseHelper.dart';
import 'user.dart';

class AgregarProducto extends StatefulWidget {
  const AgregarProducto({super.key});
  @override
  State<AgregarProducto> createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String? seleccionada;
  List<String> opciones = ['Alimentos', 'Tecnologia', 'Hogar', 'Ropa', 'Otros'];
  

   Future<void> guardar() async {
    if (_referenciaController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _precioController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        seleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    User nuevoProducto = User(
      referencia: _referenciaController.text,
      nombre: _nombreController.text,
      precio: double.parse(_precioController.text),
      descripcion: _descripcionController.text,
      categoria: seleccionada!,
    );

    await DatabaseHelper.instance.insertUser(nuevoProducto);
    Navigator.pop(context); // regresa a la anterior pantalla 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Agregar Producto", style: TextStyle(fontSize: 35, color: Colors.brown, fontWeight: FontWeight.w600)),
            Text("Llena los campos del nuevo producto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 212, 221, 225),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _referenciaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Referencia', hintText: 'Ingrese la referencia', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ingrese el nombre del producto', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _precioController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Precio', hintText: 'Ingrese el precio', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Ingrese la descripción', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 250,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: seleccionada,
                    hint: Text("Seleccione una categoria"),
                    items: opciones.map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => seleccionada = newValue);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: guardar,
                    child: Text("Agregar Producto"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}