import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/casa.dart';

class CasaRepository {
  static final CasaRepository instance = CasaRepository._instance();
  CasaRepository._instance();

  final CollectionReference _casas =
      FirebaseFirestore.instance.collection('casas');

  Stream<List<Casa>> getCasas() {
    return _casas.orderBy('casa').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Casa.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> actualizarCasa(Casa casa) async {
    await _casas.doc(casa.id).update({
      'propietario': casa.propietario,
      'emailPropietario': casa.emailPropietario,
      'inquilino': casa.inquilino,
    });
  }
}