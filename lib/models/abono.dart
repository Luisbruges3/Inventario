class Abono {
  final String id;
  final double monto;
  final DateTime fecha;

  Abono({
    required this.id,
    required this.monto,
    required this.fecha,
  });

  factory Abono.fromMap(String id, Map<String, dynamic> map) {
    return Abono(
      id: id,
      monto: (map['monto'] as num).toDouble(),
      fecha: (map['fecha'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'fecha': fecha,
    };
  }

  // Igual que en Pago — editable si tiene menos de 15 minutos
  bool get esEditable {
    return DateTime.now().difference(fecha).inMinutes < 15;
  }
}