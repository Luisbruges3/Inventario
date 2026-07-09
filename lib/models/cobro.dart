class Cobro {
  final String id;
  final String concepto;
  final double montoTotal;
  final DateTime fecha;
  final bool esMasivo;
  final String? casaNumero; // solo para cobros individuales
  final String categoria; // 'administracion' | 'extraordinario' | 'otros'
  final String? mes;

  Cobro({
    required this.id,
    required this.concepto,
    required this.montoTotal,
    required this.fecha,
    required this.esMasivo,
    this.casaNumero,
    required this.categoria,
    this.mes,
  });

  factory Cobro.fromMap(String id, Map<String, dynamic> map) {
    return Cobro(
      id: id,
      concepto: map['concepto'] ?? '',
      montoTotal: (map['montoTotal'] as num).toDouble(),
      fecha: (map['fecha'] as dynamic).toDate(),
      esMasivo: map['esMasivo'] ?? false,
      casaNumero: map['casaNumero'],
      categoria: map['categoria'] ?? 'otros',
      mes: map['mes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'concepto': concepto,
      'montoTotal': montoTotal,
      'fecha': fecha,
      'esMasivo': esMasivo,
      'casaNumero': casaNumero,
      'categoria': categoria,
      'mes': mes,
    };
  }
}