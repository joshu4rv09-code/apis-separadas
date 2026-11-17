class DobleModel {
  final int? idCalculo;
  final double numeroEntrada;
  final double resultadoDoble;
  final String? mensaje;
  final String? fechaCreacion;

  DobleModel({
    this.idCalculo,
    required this.numeroEntrada,
    required this.resultadoDoble,
    this.mensaje,
    this.fechaCreacion,
  });

  factory DobleModel.fromJson(Map<String, dynamic> json) => DobleModel(
        idCalculo: json['id_calculo'] as int?,
        numeroEntrada: (json['numero_entrada'] as num?)?.toDouble() ?? 0.0,
        resultadoDoble: (json['resultado_doble'] as num?)?.toDouble() ?? 0.0,
        mensaje: json['mensaje'] as String?,
        fechaCreacion: json['fecha_creacion'] as String?,
      );
}
