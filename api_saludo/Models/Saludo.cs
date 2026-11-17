using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace ApiSaludo.Models;

// Tabla compartida con la base de datos alarmas.db del examen
[Table("Saludos")]
public class Saludo
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    [JsonPropertyName("id_saludo")]
    public int IdSaludo { get; set; }

    [Required(ErrorMessage = "El nombre es obligatorio")]
    [MaxLength(100)]
    [JsonPropertyName("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [Required]
    [MaxLength(300)]
    [JsonPropertyName("mensaje_saludo")]
    public string MensajeSaludo { get; set; } = string.Empty;

    [Column("fecha_creacion", TypeName = "TEXT")]
    [JsonPropertyName("fecha_creacion")]
    public string FechaCreacion { get; set; } = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
}

// Tabla del examen (referencia de solo lectura – misma base de datos)
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
public class SaludoInputDto
{
    [Required(ErrorMessage = "El campo 'nombre' es obligatorio")]
    [JsonPropertyName("nombre")]
    public string? Nombre { get; set; }
}
