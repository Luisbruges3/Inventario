import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cobro.dart';
import '../models/pago.dart';
import '../models/casa.dart';
import '../models/abono.dart';
import '../repositories/cobro_repository.dart';
import '../models/detalle_pago.dart';

final cobrosStreamProvider = StreamProvider<List<Cobro>>((ref) {
  return CobroRepository.instance.getCobros();
});

final pagosStreamProvider = StreamProvider<List<Pago>>((ref) {
  return CobroRepository.instance.getPagos();
});

final pagosPendientesStreamProvider = StreamProvider<List<Pago>>((ref) {
  return CobroRepository.instance.getPagosPendientes();
});

// Provider de abonos por pago — recibe el pagoId como parámetro
final abonosStreamProvider = StreamProvider.family<List<Abono>, String>((ref, pagoId) {
  return CobroRepository.instance.getAbonos(pagoId);
});

class CobroController extends Notifier<void> {
  @override
  void build() {}

  Future<void> crearCobroMasivo({
    required String concepto,
    required double montoTotal,
    required List<Casa> casas,
    required String categoria,
    String? mes,
  }) async {
    await CobroRepository.instance.crearCobroMasivo(
      concepto: concepto,
      montoTotal: montoTotal,
      casas: casas,
      categoria: categoria,
      mes: mes,
    );
  }

  Future<void> crearCobroIndividual({
    required String concepto,
    required double montoTotal,
    required Casa casa,
    required String categoria,
  String? mes,
  }) async {
    await CobroRepository.instance.crearCobroIndividual(
      concepto: concepto,
      montoTotal: montoTotal,
      casa: casa,
      categoria: categoria,
      mes: mes,
    );
  }

  Future<bool> registrarPago({
    required Pago pago,
    required double montoPagado,
    required bool registrarSaldoAFavor,
  }) async {
    return await CobroRepository.instance.registrarPago(
      pago: pago,
      montoPagado: montoPagado,
      registrarSaldoAFavor: registrarSaldoAFavor,
    );
  }

  Future<void> eliminarAbono({
    required Pago pago,
    required Abono abono,
  }) async {
    await CobroRepository.instance.eliminarAbono(
      pago: pago,
      abono: abono,
    );
  }

Future<List<DetallePago>> distribuirPago({
  required String casaId,
  required List<Pago> pagosPendientes,
  required double montoPagado,
  required bool registrarSaldoAFavor,
  String? categoriaSaldo, // null = Todos
}) async {
  return await CobroRepository.instance.distribuirPago(
    casaId: casaId,
    pagosPendientes: pagosPendientes,
    montoPagado: montoPagado,
    registrarSaldoAFavor: registrarSaldoAFavor,
    categoriaSaldo: categoriaSaldo,
  );
}

  Future<void> editarPago({
    required String pagoId,
    required double nuevoMonto,
  }) async {
    await CobroRepository.instance.editarPago(
      pagoId: pagoId,
      nuevoMonto: nuevoMonto,
    );
  }
}

final cobroControllerProvider =
    NotifierProvider<CobroController, void>(CobroController.new);