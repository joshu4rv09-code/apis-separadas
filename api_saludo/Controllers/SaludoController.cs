using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApiSaludo.Data;
using ApiSaludo.Models;

namespace ApiSaludo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SaludoController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<SaludoController> _logger;

    public SaludoController(AppDbContext context, ILogger<SaludoController> logger)
    {
        _context = context;
        _logger = logger;
    }

    // =====================================================================
    // POST api/saludo
    // Recibe el nombre, genera el saludo, imprime en consola y guarda en SQLite
    // =====================================================================
    [HttpPost]
    public async Task<ActionResult<Saludo>> PostSaludo([FromBody] SaludoInputDto input)
    {
        if (input == null || string.IsNullOrWhiteSpace(input.Nombre))
            return BadRequest(new { mensaje = "El campo 'nombre' no puede estar vacío." });

        var nombreLimpio = input.Nombre.Trim();
        var saludoTexto = $"¡Hola, {nombreLimpio}! Bienvenido. Saludo personalizado generado correctamente.";

        // ► IMPRESIÓN EN CONSOLA DEL SERVIDOR (visible en terminal de VS Code)
        Console.WriteLine("\n" + new string('=', 60));
        Console.WriteLine("[API SALUDO] SALUDO PERSONALIZADO GENERADO:");
        Console.WriteLine($"  Nombre ingresado : {nombreLimpio}");
        Console.WriteLine($"  Saludo generado  : {saludoTexto}");
        Console.WriteLine($"  Guardando en SQLite (alarmas.db) → tabla Saludos...");
        Console.WriteLine(new string('=', 60));

        var nuevo = new Saludo
        {
            Nombre = nombreLimpio,
            MensajeSaludo = saludoTexto,
            FechaCreacion = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
        };

        try
        {
            _context.Saludos.Add(nuevo);
            await _context.SaveChangesAsync();

            Console.WriteLine($"[API SALUDO] ✓ Guardado con ID {nuevo.IdSaludo}\n");
            return CreatedAtAction(nameof(GetSaludo), new { id = nuevo.IdSaludo }, nuevo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al guardar saludo en SQLite");
            return StatusCode(500, new { mensaje = "Error al guardar en SQLite", error = ex.Message });
        }
    }

    // GET api/saludo
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Saludo>>> GetSaludos()
    {
        var lista = await _context.Saludos
            .OrderByDescending(s => s.IdSaludo)
            .ToListAsync();
        return Ok(lista);
    }

    // GET api/saludo/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<Saludo>> GetSaludo(int id)
    {
        var s = await _context.Saludos.FindAsync(id);
        if (s == null) return NotFound(new { mensaje = $"Saludo con ID {id} no encontrado." });
        return Ok(s);
    }

    // DELETE api/saludo/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSaludo(int id)
    {
        var s = await _context.Saludos.FindAsync(id);
        if (s == null) return NotFound(new { mensaje = $"Saludo con ID {id} no encontrado." });
        _context.Saludos.Remove(s);
        await _context.SaveChangesAsync();
        return Ok(new { mensaje = $"Saludo con ID {id} eliminado de SQLite." });
    }

    // GET api/saludo/alarmas  → Ver las alarmas del examen desde esta misma BD
    [HttpGet("alarmas")]
    public async Task<ActionResult<IEnumerable<Alarma>>> GetAlarmasDelExamen()
    {
        var alarmas = await _context.Alarmas
            .OrderByDescending(a => a.IdAlarma)
            .ToListAsync();
        return Ok(alarmas);
    }
}
