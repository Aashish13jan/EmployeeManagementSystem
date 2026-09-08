using EmployeeManagement.API.Models;
using Microsoft.EntityFrameworkCore;

namespace EmployeeManagement.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<Employee> Employees { get; set; } = null!;
        public DbSet<Designation> Designations { get; set; } = null!;
        public DbSet<EmployeeCompensation> EmployeeCompensations { get; set; } = null!;
        public DbSet<EmployeeEducation> EmployeeEducations { get; set; } = null!;
        public DbSet<UserRole> UserRoles { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ---------- Employee ----------
            modelBuilder.Entity<Employee>(entity =>
            {
                entity.ToTable("Employees");
                entity.HasKey(e => e.EmployeeId);

                entity.HasIndex(e => e.EmployeeCode).IsUnique();
                entity.HasIndex(e => e.Email).IsUnique();

                // Employee -> Designation (many-to-one)
                entity.HasOne(e => e.Designation)
                      .WithMany(d => d.Employees)
                      .HasForeignKey(e => e.DesignationId)
                      .OnDelete(DeleteBehavior.Restrict); // don't allow deleting a Designation that's in use

                // Self-referencing: Employee -> Manager (many-to-one, pointing back at Employees)
                entity.HasOne(e => e.Manager)
                      .WithMany(e => e.DirectReports)
                      .HasForeignKey(e => e.ManagerId)
                      .OnDelete(DeleteBehavior.Restrict); // avoid multiple cascade paths on self-FK

                entity.Property(e => e.Status).HasMaxLength(20);
            });

            // ---------- EmployeeCompensation (1:1 with Employee) ----------
            modelBuilder.Entity<EmployeeCompensation>(entity =>
            {
                entity.ToTable("EmployeeCompensation");
                entity.HasKey(c => c.CompensationId);
                entity.HasIndex(c => c.EmployeeId).IsUnique();

                entity.HasOne(c => c.Employee)
                      .WithOne(e => e.Compensation)
                      .HasForeignKey<EmployeeCompensation>(c => c.EmployeeId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.Property(c => c.Salary).HasColumnType("decimal(12,2)");
            });

            // ---------- EmployeeEducation (1:1 with Employee) ----------
            modelBuilder.Entity<EmployeeEducation>(entity =>
            {
                entity.ToTable("EmployeeEducation");
                entity.HasKey(ed => ed.EducationId);
                entity.HasIndex(ed => ed.EmployeeId).IsUnique();

                entity.HasOne(ed => ed.Employee)
                      .WithOne(e => e.Education)
                      .HasForeignKey<EmployeeEducation>(ed => ed.EmployeeId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.Property(ed => ed.Class10Percentage).HasColumnType("decimal(5,2)");
                entity.Property(ed => ed.Class12Percentage).HasColumnType("decimal(5,2)");
            });

            // ---------- Designation ----------
            modelBuilder.Entity<Designation>(entity =>
            {
                entity.ToTable("Designations");
                entity.HasKey(d => d.DesignationId);
                entity.HasIndex(d => d.Title).IsUnique();
            });

            // ---------- UserRole ----------
            modelBuilder.Entity<UserRole>(entity =>
            {
                entity.ToTable("UserRoles");
                entity.HasKey(u => u.UserRoleId);
                entity.HasIndex(u => u.UserName).IsUnique();
            });
        }
    }
}
