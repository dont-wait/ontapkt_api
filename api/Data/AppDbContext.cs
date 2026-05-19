using Microsoft.EntityFrameworkCore;
using ApiServer.Models;

namespace ApiServer.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<DanhMuc> DanhMucs => Set<DanhMuc>();
    public DbSet<GiaoDich> GiaoDichs => Set<GiaoDich>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Seed dữ liệu mẫu cho DanhMuc
        modelBuilder.Entity<DanhMuc>().HasData(
            // Danh mục CHI
            new DanhMuc { Id = 1, TenDanhMuc = "Ăn uống", LoaiDanhMuc = "chi" },
            new DanhMuc { Id = 2, TenDanhMuc = "Di chuyển", LoaiDanhMuc = "chi" },
            new DanhMuc { Id = 3, TenDanhMuc = "Mua sắm", LoaiDanhMuc = "chi" },
            new DanhMuc { Id = 4, TenDanhMuc = "Giải trí", LoaiDanhMuc = "chi" },
            new DanhMuc { Id = 5, TenDanhMuc = "Hóa đơn", LoaiDanhMuc = "chi" },
            new DanhMuc { Id = 6, TenDanhMuc = "Khác (chi)", LoaiDanhMuc = "chi" },
            // Danh mục THU
            new DanhMuc { Id = 7, TenDanhMuc = "Lương", LoaiDanhMuc = "thu" },
            new DanhMuc { Id = 8, TenDanhMuc = "Thưởng", LoaiDanhMuc = "thu" },
            new DanhMuc { Id = 9, TenDanhMuc = "Đầu tư", LoaiDanhMuc = "thu" },
            new DanhMuc { Id = 10, TenDanhMuc = "Khác (thu)", LoaiDanhMuc = "thu" }
        );

        // Seed user mẫu
        modelBuilder.Entity<User>().HasData(
            new User { Id = 1, MatKhau = "123456", HoTen = "Nguyen Van A", GioiTinh = "Nam" }
        );
    }
}
