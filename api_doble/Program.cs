using Microsoft.EntityFrameworkCore;
using ApiDoble.Data;
using ApiDoble.Models;

if (args.Length >= 2 && args[0].Equals("query", StringComparison.OrdinalIgnoreCase))
{
    var sql = args[1];

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

var builder = WebApplication.CreateBuilder(args);

var examenDbPath  = @"C:\Users\romev\OneDrive\Desktop\examen_alarma_fullstack\backend\alarmas.db";
var localDbPath   = Path.Combine(builder.Environment.ContentRootPath, "alarmas.db");

string dbFinal;
if (File.Exists(examenDbPath))
{
    dbFinal = examenDbPath;
    Console.WriteLine($"[API DOBLE] Conectado a BD del examen: {examenDbPath}");
}
else
{
    dbFinal = localDbPath;
    Console.WriteLine($"[API DOBLE] BD local: {localDbPath}");
}

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlite($"Data Source={dbFinal}"));

builder.Services.AddControllers();

builder.Services.AddCors(opt => opt.AddPolicy("AllowAll", p =>
    p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title   = "API 2 – Duplicador de Número",
        Version = "v1",
        Description =
            "API REST separada para calcular el doble de un número.\n" +
            "• POST /api/doble → calcula el doble e imprime en consola.\n" +
            "• GET  /api/doble → historial de cálculos en SQLite.\n" +
            "• Compatible con Chrome (localhost:5238) y Emulador Android API 28 (10.0.2.2:5238)."
    });
});

var app = builder.Build();

app.UseCors("AllowAll");
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API Doble v1");
    c.RoutePrefix = "swagger";
});

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}


app.MapGet("/visor", async (AppDbContext db) =>
{
    var calculos = await db.CalculosDoble.OrderByDescending(c => c.IdCalculo).ToListAsync();
    var alarmas  = await db.Alarmas.OrderByDescending(a => a.IdAlarma).ToListAsync();

    var filasC = string.Join("", calculos.Select(c =>
        $"<tr><td><b>#{c.IdCalculo}</b></td>" +
        $"<td><b style='color:#ea580c;font-size:1.1em'>{c.NumeroEntrada}</b></td>" +
        $"<td><b style='color:#16a34a;font-size:1.2em'>{c.ResultadoDoble}</b> ({c.NumeroEntrada}×2)</td>" +
        $"<td><small>{c.FechaCreacion}</small></td></tr>"));

    var filasA = string.Join("", alarmas.Select(a =>
        $"<tr><td><b>#{a.IdAlarma}</b></td><td><b style='color:#003366'>{a.Hora}</b></td>" +
        $"<td>{a.Periodicidad} min</td><td>{(a.Estado ? "✅ ACTIVA" : "⛔ DETENIDA")}</td><td><small>{a.FechaCreacion}</small></td></tr>"));

    var html = $$"""
    <!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
    <title>Visor SQLite – API Doble</title>
    <style>
      body{font-family:'Segoe UI',sans-serif;margin:28px;background:#f1f5f9}
      .card{background:#fff;border-radius:14px;padding:22px;box-shadow:0 4px 12px rgba(0,0,0,.07);margin-bottom:22px}
      h1{color:#ea580c;margin:0 0 6px}h2{margin:0 0 14px;font-size:16px}
      table{width:100%;border-collapse:collapse}
      th{background:#ea580c;color:#fff;padding:10px 14px;text-align:left;font-size:13px}
      td{padding:10px 14px;border-bottom:1px solid #e2e8f0;font-size:13px}
      tr:hover{background:#f8fafc}
      .btn{background:#ea580c;color:#fff;padding:9px 16px;border-radius:8px;text-decoration:none;font-size:13px;font-weight:600;display:inline-block;margin:4px}
      .blue{background:#003366}.green{background:#16a34a}
    </style></head><body>
    <div class="card">
      <h1>🔢 Visor SQLite — API 2: Duplicador de Número</h1>
      <p>Base de datos compartida: <code>alarmas.db</code> del proyecto examen UTH</p>
      <a href="/swagger" class="btn">📋 Swagger UI</a>
      <button onclick="location.reload()" class="btn blue">🔄 Refrescar</button>
      <span style='color:#64748b;font-size:13px;margin-left:12px'>ℹ️ Puerto 5238 (Ejecución individual por API)</span>
    </div>
    <div class="card">
      <h2>🔢 Tabla <code>CalculosDoble</code> — {{calculos.Count}} registro(s)</h2>
      <table><thead><tr><th>ID</th><th>Número Entrada</th><th>Resultado (×2)</th><th>Fecha/Hora</th></tr></thead>
      <tbody>{{(calculos.Any() ? filasC : "<tr><td colspan='4' style='color:#94a3b8;text-align:center'>Sin cálculos todavía. Usa la app Flutter o Swagger.</td></tr>")}}</tbody></table>
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
Console.WriteLine("  API 2 – DUPLICADOR DE NÚMERO  (PUERTO 5238)");
Console.WriteLine($"  Swagger en Chrome : http://localhost:5238/swagger");
Console.WriteLine($"  Visor SQLite      : http://localhost:5238/visor");
Console.WriteLine($"  Android Emulator  : http://10.0.2.2:5238");
Console.WriteLine($"  Base de datos     : {dbFinal}");
Console.WriteLine("=================================================================");

app.Run();
