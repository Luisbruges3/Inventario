class User {
  final int? id;
  final String nombre;
  final String referencia;
  final double precio;
  final String descripcion;
  final String categoria;

  User({this.id, required this.nombre, required this.referencia, required this.precio, required this.descripcion, required this.categoria});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'referencia': referencia,
      'precio': precio,
      'descripcion': descripcion,
      'categoria': categoria
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nombre: map['nombre'],
      referencia: map['referencia'],
      precio: map['precio'],
      descripcion: map['descripcion'],
      categoria: map['categoria']
    );
  }
}