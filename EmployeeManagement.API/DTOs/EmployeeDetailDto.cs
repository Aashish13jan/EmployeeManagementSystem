namespace EmployeeManagement.API.DTOs
{
    public class EmployeeDetailDto
    {
        // Personal details
        public int EmployeeId { get; set; }
        public string EmployeeCode { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime? DateOfBirth { get; set; }

        // Employment details
        public int DesignationId { get; set; }
        public string DesignationTitle { get; set; } = string.Empty;
        public int? ManagerId { get; set; }
        public string? ManagerName { get; set; }
        public DateTime JoiningDate { get; set; }
        public string Status { get; set; } = string.Empty;

        // Compensation details
        public decimal Salary { get; set; }

        // Education details
        public string? Class10SchoolName { get; set; }
        public decimal? Class10Percentage { get; set; }
        public string? Class12SchoolName { get; set; }
        public decimal? Class12Percentage { get; set; }
    }
}
