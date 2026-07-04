import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import '../repositories/firestoreHelper.dart';

final productosStreamProvider = StreamProvider<List<User>>((ref) {
  return FirestoreHelper.instance.getProductos();
});

enum ProductoAccionResultado { exito, sinConexion, camposInvalidos }

class ProductoController extends Notifier<void> {
  @override
  void build() {}

  Future<bool> _hayConexion() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<ProductoAccionResultado> agregar({
    required String nombre,
    required String referencia,
    required String precio,
    required String descripcion,
    required String? categoria,
  }) async {
    if (!await _hayConexion()) {
      return ProductoAccionResultado.sinConexion;
    }

    if (nombre.isEmpty ||
        referencia.isEmpty ||
        precio.isEmpty ||
        descripcion.isEmpty ||
        categoria == null) {
      return ProductoAccionResultado.camposInvalidos;
    }

    final nuevoProducto = User(
      referencia: referencia,
      nombre: nombre,
      precio: double.parse(precio),
      descripcion: descripcion,
      categoria: categoria,
    );

    await FirestoreHelper.instance.syncProducto(nuevoProducto);
    return ProductoAccionResultado.exito;
  }

  Future<ProductoAccionResultado> actualizar(User productoActualizado) async {
    if (!await _hayConexion()) {
      return ProductoAccionResultado.sinConexion;
    }

    await FirestoreHelper.instance.syncUpdateProducto(productoActualizado);
    return ProductoAccionResultado.exito;
  }

  Future<void> eliminar(User user) async {
    await FirestoreHelper.instance.syncDeleteProducto(user.firestoreId!);
  }
}

final productoControllerProvider =
    NotifierProvider<ProductoController, void>(ProductoController.new);