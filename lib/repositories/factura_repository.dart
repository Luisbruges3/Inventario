import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/factura.dart';

class FacturaRepository {
  static final FacturaRepository instance = FacturaRepository._instance();
  FacturaRepository._instance();

  final CollectionReference _facturas =
      FirebaseFirestore.instance.collection('facturas');

  Future<void> guardarFactura(Factura factura) async {
    await _facturas.doc(factura.id).set(factura.toMap());
  }

  Stream<List<Factura>> getFacturas() {
    return _facturas
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Factura.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}