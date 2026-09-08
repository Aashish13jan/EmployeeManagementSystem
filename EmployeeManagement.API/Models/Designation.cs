using System.ComponentModel.DataAnnotations;

namespace EmployeeManagement.API.Models
{
    public class Designation
    {
        public int DesignationId { get; set; }

        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; }

        // Navigation property: one designation has many employees
        public ICollection<Employee> Employees { get; set; } = new List<Employee>();
    }
}
