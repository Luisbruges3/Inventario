class Visita {
  final String id;
  final String casaId;
  final String casaNumero;
  final String residente;
  final String cedulaVisitante;
  final String nombreVisitante;
  final DateTime fecha;

  Visita({
    required this.id,
    required this.casaId,
    required this.casaNumero,
    required this.residente,
    required this.cedulaVisitante,
    required this.nombreVisitante,
    required this.fecha,
  });

  factory Visita.fromMap(String id, Map<String, dynamic> map) {
    return Visita(
      id: id,
      casaId: map['casaId'] ?? '',
      casaNumero: map['casaNumero'] ?? '',
      residente: map['residente'] ?? '',
      cedulaVisitante: map['cedulaVisitante'] ?? '',
      nombreVisitante: map['nombreVisitante'] ?? '',
      fecha: (map['fecha'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'casaId': casaId,
      'casaNumero': casaNumero,
      'residente': residente,
      'cedulaVisitante': cedulaVisitante,
      'nombreVisitante': nombreVisitante,
      'fecha': fecha,
    };
  }
}