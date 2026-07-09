import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visita.dart';

class VisitaRepository {
  static final VisitaRepository instance = VisitaRepository._instance();
  VisitaRepository._instance();

  final CollectionReference _visitas =
      FirebaseFirestore.instance.collection('visitas');

  Future<void> registrarVisita(Visita visita) async {
    await _visitas.add(visita.toMap());
  }

  Stream<List<Visita>> getVisitas() {
    return _visitas
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Visita.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}