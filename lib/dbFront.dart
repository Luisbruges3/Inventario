import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'databaseHelper.dart';
import 'agregarProducto.dart';
import 'user.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});
  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<String> opciones = ['Alimentos', 'Tecnologia', 'Hogar', 'Ropa', 'Otros'];
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userMaps = await DatabaseHelper.instance.queryAllUsers();
    setState(() {
      _users = userMaps.map((userMap) => User.fromMap(userMap)).toList();
    });
  }

  

  Future<void> borrar(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    _fetchUsers();
  }

  Future<void> _mostrarDialogoEditar(User user) async {
  final _editNombreController = TextEditingController(text: user.nombre);
  final _editReferenciaController = TextEditingController(text: user.referencia);
  final _editPrecioController = TextEditingController(text: user.precio.toString());
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
              );
              await DatabaseHelper.instance.updateUser(actualizado);
              Navigator.pop(context);
              _fetchUsers();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

  double get total => _users.fold(0, (sum, u) => sum + u.precio);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hola Usuario", style: TextStyle(fontSize: 35, color: Colors.brown, fontWeight: FontWeight.w600)),
                Text("Inventario de los productos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(  
        backgroundColor: Colors.brown,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarProducto()),
          );
          _fetchUsers();
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
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return productoCard(_users[index], context);
                      },
                    ),
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
                    Text('\$${user.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _mostrarDialogoEditar(user),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => borrar(user.id!),
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