class Pago {
  final String id;
  final String cobroId;
  final String casaId;
  final String casaNumero;
  final String propietario;
  final String emailPropietario;
  final String concepto;
  final double montoTotal;
  final double montoPagado;
  final double saldoPendiente;
  final double saldoAFavor;
  final bool pagado;
  final DateTime fechaCobro;
  final DateTime? fechaPago;
  final String? numeroRecibo;
  final String categoria; // NUEVO
  final String? mes;


  Pago({
    required this.id,
    required this.cobroId,
    required this.casaId,
    required this.casaNumero,
    required this.propietario,
    required this.emailPropietario,
    required this.concepto,
    required this.montoTotal,
    required this.montoPagado,
    required this.saldoPendiente,
    required this.saldoAFavor,
    required this.pagado,
    required this.fechaCobro,
    this.fechaPago,
    this.numeroRecibo,
    required this.categoria, 
    this.mes,
  });

  // Retorna true si el pago es editable (menos de 15 minutos desde fechaPago)
  bool get esEditable {
    if (fechaPago == null) return false;
    return DateTime.now().difference(fechaPago!).inMinutes < 15;
  }

  factory Pago.fromMap(String id, Map<String, dynamic> map) {
    return Pago(
      id: id,
      cobroId: map['cobroId'] ?? '',
      casaId: map['casaId'] ?? '',
      casaNumero: map['casaNumero'] ?? '',
      propietario: map['propietario'] ?? '',
      emailPropietario: map['emailPropietario'] ?? '',
      concepto: map['concepto'] ?? '',
      montoTotal: (map['montoTotal'] as num).toDouble(),
      montoPagado: (map['montoPagado'] as num).toDouble(),
      saldoPendiente: (map['saldoPendiente'] as num).toDouble(),
      saldoAFavor: (map['saldoAFavor'] as num? ?? 0).toDouble(),
      pagado: map['pagado'] ?? false,
      fechaCobro: (map['fechaCobro'] as dynamic).toDate(),
      fechaPago: map['fechaPago'] != null
          ? (map['fechaPago'] as dynamic).toDate()
          : null,
      numeroRecibo: map['numeroRecibo'],    
      categoria: map['categoria'] ?? 'otros',
      mes: map['mes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cobroId': cobroId,
      'casaId': casaId,
      'casaNumero': casaNumero,
      'propietario': propietario,
      'emailPropietario': emailPropietario,
      'concepto': concepto,
      'montoTotal': montoTotal,
      'montoPagado': montoPagado,
      'saldoPendiente': saldoPendiente,
      'saldoAFavor': saldoAFavor,
      'pagado': pagado,
      'fechaCobro': fechaCobro,
      'fechaPago': fechaPago,
      'numeroRecibo': numeroRecibo,
      'categoria': categoria,
      'mes': mes,
    };
  }
}