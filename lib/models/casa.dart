class Casa {
  final String id;
  final String numero;
  final String propietario;
  final String emailPropietario;
  final String inquilino;
  final double saldoAFavor; // genérico, para pagos en modo "Todos"
  final double saldoAFavorAdministracion;
  final double saldoAFavorExtraordinario;
  final double saldoAFavorOtros;

  Casa({
    required this.id,
    required this.numero,
    required this.propietario,
    required this.emailPropietario,
    required this.inquilino,
    required this.saldoAFavor,
    this.saldoAFavorAdministracion = 0,
    this.saldoAFavorExtraordinario = 0,
    this.saldoAFavorOtros = 0,
  });

  String get residente => inquilino.isNotEmpty ? inquilino : propietario;

  // Devuelve el saldo a favor correspondiente a una categoría específica
  double saldoAFavorPorCategoria(String categoria) {
    switch (categoria) {
      case 'administracion':
        return saldoAFavorAdministracion;
      case 'extraordinario':
        return saldoAFavorExtraordinario;
      case 'otros':
        return saldoAFavorOtros;
      default:
        return saldoAFavor;
    }
  }

  factory Casa.fromMap(String id, Map<String, dynamic> map) {
    return Casa(
      id: id,
      numero: map['casa'].toString(),
      propietario: map['propietario'] ?? '',
      emailPropietario: map['emailPropietario'] ?? '',
      inquilino: map['inquilino'] ?? '',
      saldoAFavor: (map['saldoAFavor'] as num? ?? 0).toDouble(),
      saldoAFavorAdministracion:
          (map['saldoAFavorAdministracion'] as num? ?? 0).toDouble(),
      saldoAFavorExtraordinario:
          (map['saldoAFavorExtraordinario'] as num? ?? 0).toDouble(),
      saldoAFavorOtros: (map['saldoAFavorOtros'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'casa': numero,
      'propietario': propietario,
      'emailPropietario': emailPropietario,
      'inquilino': inquilino,
      'saldoAFavor': saldoAFavor,
      'saldoAFavorAdministracion': saldoAFavorAdministracion,
      'saldoAFavorExtraordinario': saldoAFavorExtraordinario,
      'saldoAFavorOtros': saldoAFavorOtros,
    };
  }
}