using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace ApiDoble.Models;

// Tabla nueva en la misma alarmas.db del examen
[Table("CalculosDoble")]
public class CalculoDoble
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    [JsonPropertyName("id_calculo")]
    public int IdCalculo { get; set; }

    [Required]
    [JsonPropertyName("numero_entrada")]
    public double NumeroEntrada { get; set; }

    [Required]
    [JsonPropertyName("resultado_doble")]
    public double ResultadoDoble { get; set; }

    [Column("fecha_creacion", TypeName = "TEXT")]
    [JsonPropertyName("fecha_creacion")]
    public string FechaCreacion { get; set; } = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
}

// Tabla del examen (acceso compartido – misma BD)
[Table("Alarma")]
public class Alarma
{
    [Key]
    [JsonPropertyName("id_alarma")]
    public int IdAlarma { get; set; }

    [JsonPropertyName("hora")]
    public string Hora { get; set; } = string.Empty;

    [JsonPropertyName("periodicidad")]
    public int Periodicidad { get; set; } = 5;

    [JsonPropertyName("estado")]
    public bool Estado { get; set; } = true;

    [Column("fecha_creacion", TypeName = "TEXT")]
    [JsonPropertyName("fecha_creacion")]
    public string FechaCreacion { get; set; } = string.Empty;
}

// DTO de entrada
public class DobleInputDto
{
    [Required(ErrorMessage = "El campo 'numero' es obligatorio")]
    [JsonPropertyName("numero")]
    public double? Numero { get; set; }
}
