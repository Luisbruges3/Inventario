import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cobro.dart';
import '../models/pago.dart';
import '../models/casa.dart';
import '../models/abono.dart';
import '../models/detalle_pago.dart';
import '../services/recibo_service.dart';

class CobroRepository {
  static final CobroRepository instance = CobroRepository._instance();
  CobroRepository._instance();

  final CollectionReference _cobros =
      FirebaseFirestore.instance.collection('cobros');
  final CollectionReference _pagos =
      FirebaseFirestore.instance.collection('pagos');

  String _campoSaldoPorCategoria(String categoria) {
    switch (categoria) {
      case 'administracion':
        return 'saldoAFavorAdministracion';
      case 'extraordinario':
        return 'saldoAFavorExtraordinario';
      default:
        return 'saldoAFavorOtros';
    }
  }    

  Future<void> crearCobroMasivo({
    required String concepto,
    required double montoTotal,
    required List<Casa> casas,
    required String categoria,
    String? mes,
  }) async {
    final cobro = await _cobros.add({
      'concepto': concepto,
      'montoTotal': montoTotal,
      'fecha': DateTime.now(),
      'esMasivo': true,
      'categoria': categoria,
      'mes': mes,
    });

    for (final casa in casas) {
      final saldoAFavor = casa.saldoAFavorPorCategoria(categoria);
      final montoFinal = (montoTotal - saldoAFavor).clamp(0.0, montoTotal);
      final saldoAFavorRestante = (saldoAFavor - montoTotal).clamp(0.0, double.infinity);

      final pagoRef = await _pagos.add({
        'cobroId': cobro.id,
        'casaId': casa.id,
        'casaNumero': casa.numero,
        'propietario': casa.propietario,
        'emailPropietario': casa.emailPropietario,
        'concepto': concepto,
        'montoTotal': montoTotal,
        'montoPagado': montoTotal - montoFinal,
        'saldoPendiente': montoFinal,
        'saldoAFavor': 0.0,
        'pagado': montoFinal == 0,
        'fechaCobro': DateTime.now(),
        'fechaPago': montoFinal == 0 ? DateTime.now() : null,
        'categoria': categoria,
        'mes': mes,
      });

      if (saldoAFavor > 0) {
        await FirebaseFirestore.instance
            .collection('casas')
            .doc(casa.id)
            .update({_campoSaldoPorCategoria(categoria): saldoAFavorRestante});

        await ReciboService.generarYEnviarRecibo(
          casa: casa,
          detalles: [
            DetallePago(
              pagoId: pagoRef.id,
              concepto: concepto,
              monto: montoTotal - montoFinal,
            ),
          ],
          saldoPendienteRestante: montoFinal,
          cubiertoConSaldoExistente: true,
        );
      }
    }
  }

Future<void> crearCobroIndividual({
    required String concepto,
    required double montoTotal,
    required Casa casa,
    required String categoria,
    String? mes,
  }) async {
    final cobro = await _cobros.add({
      'concepto': concepto,
      'montoTotal': montoTotal,
      'fecha': DateTime.now(),
      'esMasivo': false,
      'casaNumero': casa.numero,
      'categoria': categoria,
      'mes': mes,
    });

    final saldoAFavor = casa.saldoAFavorPorCategoria(categoria);
    final montoFinal = (montoTotal - saldoAFavor).clamp(0.0, montoTotal);
    final saldoAFavorRestante = (saldoAFavor - montoTotal).clamp(0.0, double.infinity);

    final pagoRef = await _pagos.add({
      'cobroId': cobro.id,
      'casaId': casa.id,
      'casaNumero': casa.numero,
      'propietario': casa.propietario,
      'emailPropietario': casa.emailPropietario,
      'concepto': concepto,
      'montoTotal': montoTotal,
      'montoPagado': montoTotal - montoFinal,
      'saldoPendiente': montoFinal,
      'saldoAFavor': 0.0,
      'pagado': montoFinal == 0,
      'fechaCobro': DateTime.now(),
      'fechaPago': montoFinal == 0 ? DateTime.now() : null,
      'categoria': categoria,
      'mes': mes,
    });

    if (saldoAFavor > 0) {
      await FirebaseFirestore.instance
          .collection('casas')
          .doc(casa.id)
          .update({_campoSaldoPorCategoria(categoria): saldoAFavorRestante});

      await ReciboService.generarYEnviarRecibo(
        casa: casa,
        detalles: [
          DetallePago(
            pagoId: pagoRef.id,
            concepto: concepto,
            monto: montoTotal - montoFinal,
          ),
        ],
        saldoPendienteRestante: montoFinal,
        cubiertoConSaldoExistente: true,
      );
    }
  }

  Stream<List<Cobro>> getCobros() {
    return _cobros
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cobro.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Pago>> getPagos() {
    return _pagos
        .orderBy('fechaCobro', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Documentos en pagos: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return Pago.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Pago>> getPagosPendientes() {
    return _pagos
        .where('pagado', isEqualTo: false)
        .orderBy('fechaCobro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pago.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Subcolección de abonos por pago
  Stream<List<Abono>> getAbonos(String pagoId) {
    return _pagos
        .doc(pagoId)
        .collection('abonos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Abono.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<bool> registrarPago({
    required Pago pago,
    required double montoPagado,
    required bool registrarSaldoAFavor,
  }) async {
    final nuevoMontoPagado = pago.montoPagado + montoPagado;
    final nuevoSaldo = pago.montoTotal - nuevoMontoPagado;
    final pagado = nuevoSaldo <= 0;
    final saldoAFavor = nuevoSaldo < 0 ? nuevoSaldo.abs() : 0.0;

    if (nuevoSaldo < 0 && !registrarSaldoAFavor) {
      return false;
    }

    // Guardar abono en subcolección
    await _pagos.doc(pago.id).collection('abonos').add({
      'monto': montoPagado,
      'fecha': DateTime.now(),
    });

    // Actualizar el pago principal
    await _pagos.doc(pago.id).update({
      'montoPagado': nuevoMontoPagado,
      'saldoPendiente': nuevoSaldo < 0 ? 0.0 : nuevoSaldo,
      'saldoAFavor': registrarSaldoAFavor ? saldoAFavor : 0.0,
      'pagado': pagado,
      'fechaPago': pagado ? DateTime.now() : null,
    });

    return true;
  }

  Future<void> eliminarAbono({
    required Pago pago,
    required Abono abono,
  }) async {
    // Recalcular montos sin este abono
    final nuevoMontoPagado = pago.montoPagado - abono.monto;
    final nuevoSaldo = pago.montoTotal - nuevoMontoPagado;

    // Eliminar el abono de la subcolección
    await _pagos.doc(pago.id).collection('abonos').doc(abono.id).delete();

    // Actualizar el pago principal
    await _pagos.doc(pago.id).update({
      'montoPagado': nuevoMontoPagado < 0 ? 0.0 : nuevoMontoPagado,
      'saldoPendiente': nuevoSaldo,
      'saldoAFavor': 0.0,
      'pagado': false,
      'fechaPago': null,
    });
  }

  Future<void> editarPago({
    required String pagoId,
    required double nuevoMonto,
  }) async {
    final doc = await _pagos.doc(pagoId).get();
    final data = doc.data() as Map<String, dynamic>;
    final montoPagado = (data['montoPagado'] as num).toDouble();
    final nuevoSaldo = nuevoMonto - montoPagado;
    final pagado = nuevoSaldo <= 0;

    await _pagos.doc(pagoId).update({
      'montoTotal': nuevoMonto,
      'saldoPendiente': nuevoSaldo < 0 ? 0.0 : nuevoSaldo,
      'pagado': pagado,
    });
  }

Future<List<DetallePago>> distribuirPago({
    required String casaId,
    required List<Pago> pagosPendientes,
    required double montoPagado,
    required bool registrarSaldoAFavor,
    String? categoriaSaldo, // null = Todos
  }) async {
    pagosPendientes.sort((a, b) => a.fechaCobro.compareTo(b.fechaCobro));

    // Si se seleccionó una categoría específica, solo pagar esa categoría
    if (categoriaSaldo != null) {
      pagosPendientes = pagosPendientes
          .where((p) => p.categoria == categoriaSaldo)
          .toList();
    }

    double montoRestante = montoPagado;
    final detalles = <DetallePago>[];

    for (final pago in pagosPendientes) {
      if (montoRestante <= 0) break;

      final saldoPendiente = pago.saldoPendiente;

      if (montoRestante >= saldoPendiente) {
        montoRestante -= saldoPendiente;

        await _pagos.doc(pago.id).collection('abonos').add({
          'monto': saldoPendiente,
          'fecha': DateTime.now(),
        });

        await _pagos.doc(pago.id).update({
          'montoPagado': pago.montoTotal,
          'saldoPendiente': 0.0,
          'pagado': true,
          'fechaPago': DateTime.now(),
        });

        detalles.add(
          DetallePago(
            pagoId: pago.id,
            concepto: pago.concepto,
            monto: saldoPendiente,
          ),
        );
      } else {
        final nuevoMontoPagado = pago.montoPagado + montoRestante;
        final nuevoSaldo = pago.saldoPendiente - montoRestante;

        await _pagos.doc(pago.id).collection('abonos').add({
          'monto': montoRestante,
          'fecha': DateTime.now(),
        });

        await _pagos.doc(pago.id).update({
          'montoPagado': nuevoMontoPagado,
          'saldoPendiente': nuevoSaldo,
          'pagado': false,
        });

        detalles.add(
          DetallePago(
            pagoId: pago.id,
            concepto: pago.concepto,
            monto: montoRestante,
          ),
        );

        montoRestante = 0;
      }
    }

    // Registrar saldo a favor
    if (montoRestante > 0 && registrarSaldoAFavor) {
      final campo = categoriaSaldo == null
          ? 'saldoAFavor'
          : _campoSaldoPorCategoria(categoriaSaldo);

      final casaDoc =
          FirebaseFirestore.instance.collection('casas').doc(casaId);
      final casaSnap = await casaDoc.get();
      final saldoActual = (casaSnap.data()?[campo] as num? ?? 0).toDouble();

      await casaDoc.update({campo: saldoActual + montoRestante});
    }

    return detalles;
  }

    // NUEVO — estampa el mismo número de recibo en todos los pagos que
    // formaron parte de esta transacción
    Future<void> asignarNumeroRecibo({
      required List<String> pagoIds,
      required String numeroRecibo,
    }) async {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in pagoIds) {
        batch.update(_pagos.doc(id), {'numeroRecibo': numeroRecibo});
      }
      await batch.commit();
    }

}