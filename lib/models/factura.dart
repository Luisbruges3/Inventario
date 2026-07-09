class Factura {
  final String id;
  final String numero;
  final String trabajador;
  final String emailTrabajador;
  final String concepto;
  final double valor;
  final DateTime fecha;

  Factura({
    required this.id,
    required this.numero,
    required this.trabajador,
    required this.emailTrabajador,
    required this.concepto,
    required this.valor,
    required this.fecha,
  });

  factory Factura.fromMap(String id, Map<String, dynamic> map) {
    return Factura(
      id: id,
      numero: map['numero'] ?? '',
      trabajador: map['trabajador'] ?? '',
      emailTrabajador: map['emailTrabajador'] ?? '',
      concepto: map['concepto'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      fecha: (map['fecha'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'trabajador': trabajador,
      'emailTrabajador': emailTrabajador,
      'concepto': concepto,
      'valor': valor,
      'fecha': fecha,
    };
  }
}