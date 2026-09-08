namespace EmployeeManagement.API.DTOs
{
    public class EmployeeListDto
    {
        public int EmployeeId { get; set; }
        public string EmployeeCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Designation { get; set; } = string.Empty;
        public string? ManagerName { get; set; }
        public DateTime JoiningDate { get; set; }
        public string Status { get; set; } = string.Empty;
    }
}
