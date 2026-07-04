import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../controllers/producto_controller.dart';
import 'agregarProducto.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserList extends ConsumerWidget {
  final bool esAdmin;
  const UserList({super.key, required this.esAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatoPrecio = NumberFormat('#,###', 'es_CO');
    final productosAsync = ref.watch(productosStreamProvider);

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
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF1565C0)),
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
            },
          ),
        ],
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
                    child: productosAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (productos) {
                        final total = productos.fold(0.0, (sum, u) => sum + u.precio);
                        return Column(
                          children: [
                            Text(
                              "Total: \$${formatoPrecio.format(total)}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: productos.length,
                                itemBuilder: (context, index) {
                                  return _ProductoCard(
                                    user: productos[index],
                                    formatoPrecio: formatoPrecio,
                                    esAdmin: esAdmin,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
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
}

class _ProductoCard extends ConsumerWidget {
  final User user;
  final NumberFormat formatoPrecio;
  final bool esAdmin;

  const _ProductoCard({
    required this.user,
    required this.formatoPrecio,
    required this.esAdmin,
  });

  Future<void> _mostrarDialogoEditar(BuildContext context, WidgetRef ref) async {
    final editNombreController = TextEditingController(text: user.nombre);
    final editReferenciaController = TextEditingController(text: user.referencia);
    final editPrecioController = TextEditingController(text: user.precio.toInt().toString());
    final editDescripcionController = TextEditingController(text: user.descripcion);
    String? editCategoria = user.categoria;
    final opciones = ['Alimentos', 'Tecnologia', 'Hogar', 'Ropa', 'Otros'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: editNombreController,
                  decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: editReferenciaController,
                  decoration: InputDecoration(labelText: 'Referencia', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: editPrecioController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: editDescripcionController,
                  decoration: InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: editCategoria,
                  items: opciones.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setStateDialog(() => editCategoria = val),
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
                final productoActualizado = User(
                  id: user.id,
                  nombre: editNombreController.text,
                  referencia: editReferenciaController.text,
                  precio: double.parse(editPrecioController.text),
                  descripcion: editDescripcionController.text,
                  categoria: editCategoria!,
                  firestoreId: user.firestoreId,
                );

                final resultado = await ref
                    .read(productoControllerProvider.notifier)
                    .actualizar(productoActualizado);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (resultado == ProductoAccionResultado.sinConexion) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sin conexión a internet. Conéctate para guardar.')),
                    );
                  }
                }
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onPressed: () => _mostrarDialogoEditar(context, ref),
              ),
              if (esAdmin)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Eliminar producto'),
                        content: Text('¿Estás seguro de que quieres eliminar "${user.nombre}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await ref
                          .read(productoControllerProvider.notifier)
                          .eliminar(user);
                    }
                  },
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