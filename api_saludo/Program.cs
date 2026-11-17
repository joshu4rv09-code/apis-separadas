using Microsoft.EntityFrameworkCore;
using ApiSaludo.Data;
using ApiSaludo.Models;

// =====================================================================
// MODO CLI: consultar SQLite desde la terminal de VS Code
// Ejemplo: dotnet run -- query "SELECT * FROM Saludos"
// =====================================================================
if (args.Length >= 2 && args[0].Equals("query", StringComparison.OrdinalIgnoreCase))
{
    var sql = args[1];

    // Intentar con la base de datos del examen primero
    var examenDb = @"C:\Users\romev\OneDrive\Desktop\examen_alarma_fullstack\backend\alarmas.db";
    var localDb  = Path.Combine(Directory.GetCurrentDirectory(), "alarmas.db");
    var dbPath   = File.Exists(examenDb) ? examenDb : localDb;

    Console.WriteLine($"\n[CLI SQLite] Base de datos: {dbPath}");
    Console.WriteLine($"[SQL] {sql}\n");

    var opts = new DbContextOptionsBuilder<AppDbContext>()
        .UseSqlite($"Data Source={dbPath}").Options;
    using var cliDb = new AppDbContext(opts);
    using var conn  = cliDb.Database.GetDbConnection();
    conn.Open();
    using var cmd = conn.CreateCommand();
    cmd.CommandText = sql;
    using var reader = cmd.ExecuteReader();
    int cols = reader.FieldCount;
    for (int i = 0; i < cols; i++) Console.Write($"{reader.GetName(i),-22} | ");
    Console.WriteLine("\n" + new string('-', cols * 25));
    int count = 0;
    while (reader.Read())
    {
        count++;
        for (int i = 0; i < cols; i++)
        {
            var val = reader.IsDBNull(i) ? "NULL" : reader.GetValue(i)?.ToString() ?? "";
            Console.Write($"{val,-22} | ");
        }
        Console.WriteLine();
    }
    Console.WriteLine($"\nTotal: {count} registro(s)\n");
    return;
}

// =====================================================================
// INICIO DE LA API
// =====================================================================
var builder = WebApplication.CreateBuilder(args);

// Ruta de la base de datos compartida con el proyecto examen
var examenDbPath  = @"C:\Users\romev\OneDrive\Desktop\examen_alarma_fullstack\backend\alarmas.db";
var localDbPath   = Path.Combine(builder.Environment.ContentRootPath, "alarmas.db");

string dbFinal;
if (File.Exists(examenDbPath))
{
    dbFinal = examenDbPath;
    Console.WriteLine($"[API SALUDO] Conectado a BD del examen: {examenDbPath}");
}
else
{
    dbFinal = localDbPath;
    Console.WriteLine($"[API SALUDO] BD local: {localDbPath}");
}

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlite($"Data Source={dbFinal}"));

builder.Services.AddControllers();

// CORS amplio: Chrome (localhost) + Android Emulator (10.0.2.2)
builder.Services.AddCors(opt => opt.AddPolicy("AllowAll", p =>
    p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title   = "API 1 – Saludo Personalizado",
        Version = "v1",
        Description =
            "API REST separada para el saludo personalizado.\n" +
            "• POST /api/saludo → genera un saludo e imprime en consola.\n" +
            "• GET  /api/saludo → historial de saludos en SQLite.\n" +
            "• Compatible con Chrome (localhost:5238) y Emulador Android API 28 (10.0.2.2:5238)."
    });
});

var app = builder.Build();

app.UseCors("AllowAll");
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API Saludo v1");
    c.RoutePrefix = "swagger";
});

// Crear tabla Saludos si no existe (no toca la tabla Alarma del examen)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

// Visor HTML en Chrome
app.MapGet("/visor", async (AppDbContext db) =>
{
    var saludos = await db.Saludos.OrderByDescending(s => s.IdSaludo).ToListAsync();
    var alarmas  = await db.Alarmas.OrderByDescending(a => a.IdAlarma).ToListAsync();

    var filasS = string.Join("", saludos.Select(s =>
        $"<tr><td><b>#{s.IdSaludo}</b></td><td><b style='color:#003366'>{s.Nombre}</b></td>" +
        $"<td>{s.MensajeSaludo}</td><td><small>{s.FechaCreacion}</small></td></tr>"));

    var filasA = string.Join("", alarmas.Select(a =>
        $"<tr><td><b>#{a.IdAlarma}</b></td><td><b style='color:#003366'>{a.Hora}</b></td>" +
        $"<td>{a.Periodicidad} min</td><td>{(a.Estado ? "✅ ACTIVA" : "⛔ DETENIDA")}</td><td><small>{a.FechaCreacion}</small></td></tr>"));

    var html = $$"""
    <!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
    <title>Visor SQLite – API Saludo</title>
    <style>
      body{font-family:'Segoe UI',sans-serif;margin:28px;background:#f1f5f9}
      .card{background:#fff;border-radius:14px;padding:22px;box-shadow:0 4px 12px rgba(0,0,0,.07);margin-bottom:22px}
      h1{color:#003366;margin:0 0 6px}h2{margin:0 0 14px;font-size:16px}
      table{width:100%;border-collapse:collapse}
      th{background:#003366;color:#fff;padding:10px 14px;text-align:left;font-size:13px}
      td{padding:10px 14px;border-bottom:1px solid #e2e8f0;font-size:13px}
      tr:hover{background:#f8fafc}
      .btn{background:#003366;color:#fff;padding:9px 16px;border-radius:8px;text-decoration:none;font-size:13px;font-weight:600;display:inline-block;margin:4px}
      .orange{background:#ea580c}.green{background:#16a34a}
    </style></head><body>
    <div class="card">
      <h1>🗄️ Visor SQLite — API 1: Saludo Personalizado</h1>
      <p>Base de datos compartida: <code>alarmas.db</code> del proyecto examen UTH</p>
      <a href="/swagger" class="btn orange">📋 Swagger UI</a>
      <button onclick="location.reload()" class="btn">🔄 Refrescar</button>
      <span style='color:#64748b;font-size:13px;margin-left:12px'>ℹ️ Puerto 5238 (Ejecución individual por API)</span>
    </div>
    <div class="card">
      <h2>👋 Tabla <code>Saludos</code> — {{saludos.Count}} registro(s)</h2>
      <table><thead><tr><th>ID</th><th>Nombre</th><th>Saludo Generado</th><th>Fecha/Hora</th></tr></thead>
      <tbody>{{(saludos.Any() ? filasS : "<tr><td colspan='4' style='color:#94a3b8;text-align:center'>Sin saludos todavía. Usa la app Flutter o Swagger.</td></tr>")}}</tbody></table>
    </div>
    <div class="card">
      <h2>⏰ Tabla <code>Alarma</code> del examen — {{alarmas.Count}} registro(s)</h2>
      <table><thead><tr><th>ID</th><th>Hora</th><th>Periodicidad</th><th>Estado</th><th>Fecha/Hora</th></tr></thead>
      <tbody>{{(alarmas.Any() ? filasA : "<tr><td colspan='5' style='color:#94a3b8;text-align:center'>Sin alarmas.</td></tr>")}}</tbody></table>
    </div>
    </body></html>
    """;
    return Results.Content(html, "text/html; charset=utf-8");
});

app.MapGet("/", () => Results.Redirect("/swagger"));
app.MapControllers();

Console.WriteLine("=================================================================");
Console.WriteLine("🚀  API 1 – SALUDO PERSONALIZADO  (PUERTO 5238)");
Console.WriteLine($"📌  Swagger en Chrome : http://localhost:5238/swagger");
Console.WriteLine($"📌  Visor SQLite      : http://localhost:5238/visor");
Console.WriteLine($"📌  Android Emulator  : http://10.0.2.2:5238");
Console.WriteLine($"📌  Base de datos     : {dbFinal}");
Console.WriteLine("=================================================================");

app.Run();
