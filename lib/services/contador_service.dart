import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContadorService {
  /// Consecutivo único y compartido para recibos y facturas —
  /// mismo prefijo REC, mismo contador, sin distinción de tipo.
  static Future<String> generarNumero() async {
    final docRef =
        FirebaseFirestore.instance.collection('contadores').doc('general');

    final nuevoConsecutivo =
        await FirebaseFirestore.instance.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final actual =
          snapshot.exists ? (snapshot.data()!['ultimo'] as num).toInt() : 0;
      final nuevo = actual + 1;

      transaction.set(docRef, {'ultimo': nuevo}, SetOptions(merge: true));

      return nuevo;
    });

    final fecha = DateFormat('yyyyMMdd').format(DateTime.now());
    final consecutivo = nuevoConsecutivo.toString().padLeft(5, '0');

    return 'REC-$fecha-$consecutivo';
  }
}