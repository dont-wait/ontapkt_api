namespace ApiServer.Models;

public class DanhMuc
{
    public int Id { get; set; }
    public string TenDanhMuc { get; set; } = "";
    public int? IdDanhMucCha { get; set; }
    public string LoaiDanhMuc { get; set; } = ""; // "thu" hoặc "chi"
}
