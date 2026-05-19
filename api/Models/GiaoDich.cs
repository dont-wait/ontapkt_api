namespace ApiServer.Models;

public class GiaoDich
{
    public int Id { get; set; }
    public string Ngay { get; set; } = "";           // yyyy-MM-dd
    public string Loai { get; set; } = "";            // "thu" hoặc "chi"
    public double TongTien { get; set; }
    public string MoTa { get; set; } = "";
    public int DanhMucId { get; set; }
    public string HinhMinhHoa { get; set; } = "";
    public int UserId { get; set; }
}
