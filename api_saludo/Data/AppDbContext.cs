using Microsoft.EntityFrameworkCore;
using ApiSaludo.Models;

namespace ApiSaludo.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // Tabla nueva que se crea en la misma alarmas.db del examen
    public DbSet<Saludo> Saludos => Set<Saludo>();

    // Tabla del examen (acceso de solo lectura compartido)
    public DbSet<Alarma> Alarmas => Set<Alarma>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Saludo>(entity =>
        {
            entity.ToTable("Saludos");
            entity.HasKey(e => e.IdSaludo);
            entity.Property(e => e.IdSaludo).HasColumnName("id_saludo").ValueGeneratedOnAdd();
            entity.Property(e => e.Nombre).HasColumnName("nombre").HasMaxLength(100).IsRequired();
            entity.Property(e => e.MensajeSaludo).HasColumnName("mensaje_saludo").HasMaxLength(300).IsRequired();
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
