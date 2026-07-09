import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visita.dart';
import '../repositories/visita_repository.dart';
import '../repositories/casa_repository.dart';
import '../models/casa.dart';

// Provider que expone el stream de casas para el dropdown
final casasStreamProvider = StreamProvider<List<Casa>>((ref) {
  return CasaRepository.instance.getCasas();
});

// Provider que expone el stream de visitas para el historial
final visitasStreamProvider = StreamProvider<List<Visita>>((ref) {
  return VisitaRepository.instance.getVisitas();
});

class VisitaController extends Notifier<void> {
  @override
  void build() {}

  Future<void> registrarVisita({
    required Casa casa,
    required String cedulaVisitante,
    required String nombreVisitante,
  }) async {
    final visita = Visita(
      id: '',
      casaId: casa.id,
      casaNumero: casa.numero,
      residente: casa.residente,
      cedulaVisitante: cedulaVisitante,
      nombreVisitante: nombreVisitante,
      fecha: DateTime.now(),
    );

    await VisitaRepository.instance.registrarVisita(visita);
  }
}

final visitaControllerProvider =
    NotifierProvider<VisitaController, void>(VisitaController.new);