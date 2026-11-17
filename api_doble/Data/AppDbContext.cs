using Microsoft.EntityFrameworkCore;
using ApiDoble.Models;

namespace ApiDoble.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<CalculoDoble> CalculosDoble => Set<CalculoDoble>();
    public DbSet<Alarma> Alarmas => Set<Alarma>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<CalculoDoble>(entity =>
        {
            entity.ToTable("CalculosDoble");
            entity.HasKey(e => e.IdCalculo);
            entity.Property(e => e.IdCalculo).HasColumnName("id_calculo").ValueGeneratedOnAdd();
            entity.Property(e => e.NumeroEntrada).HasColumnName("numero_entrada").IsRequired();
            entity.Property(e => e.ResultadoDoble).HasColumnName("resultado_doble").IsRequired();
            entity.Property(e => e.FechaCreacion).HasColumnName("fecha_creacion");
        });

        modelBuilder.Entity<Alarma>(entity =>
        {
            entity.ToTable("Alarma");
            entity.HasKey(e => e.IdAlarma);
            entity.Property(e => e.IdAlarma).HasColumnName("id_alarma");
            entity.Property(e => e.Hora).HasColumnName("hora");
            entity.Property(e => e.Periodicidad).HasColumnName("periodicidad");
            entity.Property(e => e.Estado).HasColumnName("estado");
            entity.Property(e => e.FechaCreacion).HasColumnName("fecha_creacion");
        });
    }
}
