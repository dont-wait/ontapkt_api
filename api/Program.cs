using Microsoft.EntityFrameworkCore;
using ApiServer.Data;
using ApiServer.Models;

var builder = WebApplication.CreateBuilder(args);

// Cấu hình SQLite
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("Data Source=app.db"));

// Cho phép CORS từ Flutter
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var app = builder.Build();
app.UseCors();

// Tự động tạo database + seed dữ liệu
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

// ==================== AUTH ====================

// Đăng nhập: POST /api/login
app.MapPost("/api/login", async (AppDbContext db, LoginRequest req) =>
{
    var user = await db.Users.FirstOrDefaultAsync(u => u.Id == req.Id && u.MatKhau == req.MatKhau);
    if (user == null)
        return Results.BadRequest(new { message = "Sai ID hoặc mật khẩu" });
    return Results.Ok(user);
});

// ==================== USER ====================

app.MapGet("/api/users", async (AppDbContext db) =>
    Results.Ok(await db.Users.ToListAsync()));

app.MapGet("/api/users/{id}", async (AppDbContext db, int id) =>
{
    var user = await db.Users.FindAsync(id);
    return user is null ? Results.NotFound() : Results.Ok(user);
});

app.MapPost("/api/users", async (AppDbContext db, User user) =>
{
    db.Users.Add(user);
    await db.SaveChangesAsync();
    return Results.Created($"/api/users/{user.Id}", user);
});

// ==================== DANH MỤC ====================

app.MapGet("/api/danhmuc", async (AppDbContext db, string? loai) =>
{
    var query = db.DanhMucs.AsQueryable();
    if (!string.IsNullOrEmpty(loai))
        query = query.Where(d => d.LoaiDanhMuc == loai);
    return Results.Ok(await query.ToListAsync());
});

// ==================== GIAO DỊCH ====================

// Lấy danh sách giao dịch theo user
app.MapGet("/api/giaodich", async (AppDbContext db, int userId) =>
{
    var list = await db.GiaoDichs
        .Where(g => g.UserId == userId)
        .OrderByDescending(g => g.Ngay)
        .ToListAsync();
    return Results.Ok(list);
});

// Thêm giao dịch mới
app.MapPost("/api/giaodich", async (AppDbContext db, GiaoDich gd) =>
{
    db.GiaoDichs.Add(gd);
    await db.SaveChangesAsync();
    return Results.Created($"/api/giaodich/{gd.Id}", gd);
});

// Tổng hợp thu chi theo user
app.MapGet("/api/giaodich/tonghop", async (AppDbContext db, int userId) =>
{
    var giaoDichs = await db.GiaoDichs.Where(g => g.UserId == userId).ToListAsync();
    var tongThu = giaoDichs.Where(g => g.Loai == "thu").Sum(g => g.TongTien);
    var tongChi = giaoDichs.Where(g => g.Loai == "chi").Sum(g => g.TongTien);
    return Results.Ok(new { tongThu, tongChi });
});

app.Run();

// DTO cho đăng nhập
public record LoginRequest(int Id, string MatKhau);
