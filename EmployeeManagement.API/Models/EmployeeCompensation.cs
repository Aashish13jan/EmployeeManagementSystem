namespace EmployeeManagement.API.Models
{
    public class EmployeeCompensation
    {
        public int CompensationId { get; set; }

        public int EmployeeId { get; set; }
        public Employee? Employee { get; set; }

        public decimal Salary { get; set; }

        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}
