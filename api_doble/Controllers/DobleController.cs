using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApiDoble.Data;
using ApiDoble.Models;

namespace ApiDoble.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DobleController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<DobleController> _logger;

    public DobleController(AppDbContext context, ILogger<DobleController> logger)
    {
        _context = context;
        _logger = logger;
    }

    // =====================================================================
    // POST api/doble
    // Recibe un número, calcula su doble, imprime en consola y guarda en SQLite
    // =====================================================================
    [HttpPost]
    public async Task<ActionResult<object>> PostDoble([FromBody] DobleInputDto input)
    {
        if (input == null || !input.Numero.HasValue)
            return BadRequest(new { mensaje = "El campo 'numero' no puede ser nulo." });

        double entrada = input.Numero.Value;
        double doble   = entrada * 2.0;

        // ► IMPRESIÓN EN CONSOLA DEL SERVIDOR (visible en terminal de VS Code)
        Console.WriteLine("\n" + new string('=', 60));
        Console.WriteLine("[API DOBLE] CÁLCULO DEL DOBLE DE UN NÚMERO:");
        Console.WriteLine($"  Número ingresado  : {entrada}");
        Console.WriteLine($"  Resultado (x2)    : {doble}  ({entrada} × 2 = {doble})");
        Console.WriteLine($"  Guardando en SQLite (alarmas.db) → tabla CalculosDoble...");
        Console.WriteLine(new string('=', 60));

        var nuevo = new CalculoDoble
        {
            NumeroEntrada  = entrada,
            ResultadoDoble = doble,
            FechaCreacion  = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
        };

        try
        {
            _context.CalculosDoble.Add(nuevo);
            await _context.SaveChangesAsync();

            Console.WriteLine($"[API DOBLE] ✓ Guardado con ID {nuevo.IdCalculo}\n");

            return CreatedAtAction(nameof(GetDoble), new { id = nuevo.IdCalculo }, new
            {
                id_calculo      = nuevo.IdCalculo,
                numero_entrada  = nuevo.NumeroEntrada,
                resultado_doble = nuevo.ResultadoDoble,
                mensaje         = $"El doble de {entrada} es {doble}",
                fecha_creacion  = nuevo.FechaCreacion
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al guardar cálculo en SQLite");
            return StatusCode(500, new { mensaje = "Error al guardar en SQLite", error = ex.Message });
        }
    }

    // GET api/doble
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CalculoDoble>>> GetDobles()
    {
        var lista = await _context.CalculosDoble
            .OrderByDescending(c => c.IdCalculo)
            .ToListAsync();
        return Ok(lista);
    }

    // GET api/doble/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<CalculoDoble>> GetDoble(int id)
    {
        var c = await _context.CalculosDoble.FindAsync(id);
        if (c == null) return NotFound(new { mensaje = $"Cálculo con ID {id} no encontrado." });
        return Ok(c);
    }

    // DELETE api/doble/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteDoble(int id)
    {
        var c = await _context.CalculosDoble.FindAsync(id);
        if (c == null) return NotFound(new { mensaje = $"Cálculo con ID {id} no encontrado." });
        _context.CalculosDoble.Remove(c);
        await _context.SaveChangesAsync();
        return Ok(new { mensaje = $"Cálculo con ID {id} eliminado de SQLite." });
    }

    // GET api/doble/alarmas  → Ver alarmas del examen desde la misma BD
    [HttpGet("alarmas")]
    public async Task<ActionResult<IEnumerable<Alarma>>> GetAlarmasDelExamen()
    {
        var alarmas = await _context.Alarmas
            .OrderByDescending(a => a.IdAlarma)
            .ToListAsync();
        return Ok(alarmas);
    }
}
