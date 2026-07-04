import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreHelper {
  static final FirestoreHelper instance = FirestoreHelper._instance();
  FirestoreHelper._instance();

  final CollectionReference _productos = FirebaseFirestore.instance.collection('productos');

  Future<String> syncProducto(User user) async {
    final docRef = await _productos.add({
      'id': user.id, 
      'referencia': user.referencia,
      'nombre': user.nombre,
      'precio': user.precio,
      'descripcion': user.descripcion,
      'categoria': user.categoria,
    });

    // actualizar el documento con su propio firestoreId
    await _productos.doc(docRef.id).update({'firestoreId': docRef.id});
    
    return docRef.id;
  }

  Future syncDeleteProducto (String firestoreId)async{
    await _productos.doc(firestoreId).delete();
  }

  Future syncUpdateProducto (User user)async{
    await _productos.doc(user.firestoreId).update({
      'referencia': user.referencia,
      'nombre': user.nombre,
      'precio': user.precio,
      'descripcion': user.descripcion,
      'categoria': user.categoria,
    });
  }

  Stream<List<User>> getProductos() {
  return _productos.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return User.fromMap(data);
      }).toList();
    });
  }

  
}