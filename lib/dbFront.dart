import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agregarProducto.dart';
import 'user.dart';
import 'firestoreHelper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});
  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<String> opciones = ['Alimentos', 'Tecnologia', 'Hogar', 'Ropa', 'Otros'];

  @override
  void initState() {
    super.initState(); 
  }

  final formatoPrecio = NumberFormat('#,###', 'es_CO');

  Future<void> borrar(User user) async {
    await FirestoreHelper.instance.syncDeleteProducto(user.firestoreId!);
  }

  Future<void> _mostrarDialogoEditar(User user) async {
   final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sin conexión a internet. Conéctate para guardar.')),
      );
      return;
    } 

  final _editNombreController = TextEditingController(text: user.nombre);
  final _editReferenciaController = TextEditingController(text: user.referencia);
  final _editPrecioController = TextEditingController(text: user.precio.toInt().toString());
  final _editDescripcionController = TextEditingController(text: user.descripcion);
  String? _editCategoria = user.categoria;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _editNombreController,
                decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _editReferenciaController,
                decoration: InputDecoration(labelText: 'Referencia', border: OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _editPrecioController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _editDescripcionController,
                decoration: InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: _editCategoria,
                items: opciones.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setStateDialog(() => _editCategoria = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              User actualizado = User(
                id: user.id,
                nombre: _editNombreController.text,
                referencia: _editReferenciaController.text,
                precio: double.parse(_editPrecioController.text),
                descripcion: _editDescripcionController.text,
                categoria: _editCategoria!,
                firestoreId: user.firestoreId
              );
              await FirestoreHelper.instance.syncUpdateProducto(actualizado);
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFFE3F2FD),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hola Usuario", style: TextStyle(fontSize: 35, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
                Text("Inventario de los productos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(  
        backgroundColor: Color(0xFF1565C0),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarProducto()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Inventario Actual", style: TextStyle(fontSize: 30, color: Colors.black)),
                  SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<List<User>>(
                      stream: FirestoreHelper.instance.getProductos(),
                      builder:(context,snapshot){
                      if(snapshot.hasData){
                          final productos = snapshot.data!;
                          final total = productos.fold(0.0, (sum, u) => sum + u.precio);
                          
                          return Column(
                            children: [
                              Text("Total: \$${formatoPrecio.format(total)}", 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                              
                              Expanded(
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return productoCard(snapshot.data![index], context);
                                  },)
                                ),
                              ]
                            );
                        
                      }else{
                        return CircularProgressIndicator();
                        }
                      }
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget productoCard(User user, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nombre, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text(user.referencia, style: TextStyle(fontSize: 15)),
                    Text('\$${formatoPrecio.format(user.precio)}', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _mostrarDialogoEditar(user),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => borrar(user),
              ),
            ],
          ),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.descripcion, style: TextStyle(fontSize: 15)),
            ])),
          ]),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.categoria, style: TextStyle(fontSize: 15)),
              Divider(height: 1, color: Colors.grey[350]),
            ])),
          ]),
        ],
      ),
    );
  }
}