namespace ApiServer.Models;

public class User
{
    public int Id { get; set; }
    public string MatKhau { get; set; } = "";
    public string HoTen { get; set; } = "";
    public string GioiTinh { get; set; } = "";
    public string HinhMinhHoa { get; set; } = "";
}
