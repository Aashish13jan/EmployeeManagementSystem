namespace EmployeeManagement.API.Models
{
    public class EmployeeEducation
    {
        public int EducationId { get; set; }

        public int EmployeeId { get; set; }
        public Employee? Employee { get; set; }

        public string? Class10SchoolName { get; set; }
        public decimal? Class10Percentage { get; set; }

        public string? Class12SchoolName { get; set; }
        public decimal? Class12Percentage { get; set; }

        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}
