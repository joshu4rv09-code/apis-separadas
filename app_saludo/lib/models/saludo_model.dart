class SaludoModel {
  final int? idSaludo;
  final String nombre;
  final String mensajeSaludo;
  final String? fechaCreacion;

  SaludoModel({
    this.idSaludo,
    required this.nombre,
    required this.mensajeSaludo,
    this.fechaCreacion,
  });

  factory SaludoModel.fromJson(Map<String, dynamic> json) => SaludoModel(
        idSaludo: json['id_saludo'] as int?,
        nombre: json['nombre'] as String? ?? '',
        mensajeSaludo: json['mensaje_saludo'] as String? ?? '',
        fechaCreacion: json['fecha_creacion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (idSaludo != null) 'id_saludo': idSaludo,
        'nombre': nombre,
        'mensaje_saludo': mensajeSaludo,
        if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      };
}
