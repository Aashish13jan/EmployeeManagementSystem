using System.ComponentModel.DataAnnotations;

namespace EmployeeManagement.API.DTOs
{
    public class EmployeeUpdateDto
    {
        // Note: EmployeeId itself comes from the route (/api/employees/{id}),
        // not from the body - standard REST convention, avoids a mismatch
        // between the URL id and a body id.

        [Required(ErrorMessage = "Employee code is required.")]
        [StringLength(20)]
        public string EmployeeCode { get; set; } = string.Empty;

        [Required(ErrorMessage = "First name is required.")]
        [StringLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last name is required.")]
        [StringLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Enter a valid email address.")]
        [StringLength(150)]
        public string Email { get; set; } = string.Empty;

        [Phone(ErrorMessage = "Enter a valid phone number.")]
        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [Required(ErrorMessage = "Designation is required.")]
        public int DesignationId { get; set; }

        public int? ManagerId { get; set; }

        [Required(ErrorMessage = "Joining date is required.")]
        public DateTime JoiningDate { get; set; }

        [Required]
        [RegularExpression("^(Active|Inactive)$", ErrorMessage = "Status must be Active or Inactive.")]
        public string Status { get; set; } = "Active";

        [Required(ErrorMessage = "Salary is required.")]
        [Range(0, double.MaxValue, ErrorMessage = "Salary cannot be negative.")]
        public decimal Salary { get; set; }

        [StringLength(150)]
        public string? Class10SchoolName { get; set; }

        [Range(0, 100, ErrorMessage = "Class 10 percentage must be between 0 and 100.")]
        public decimal? Class10Percentage { get; set; }

        [StringLength(150)]
        public string? Class12SchoolName { get; set; }

        [Range(0, 100, ErrorMessage = "Class 12 percentage must be between 0 and 100.")]
        public decimal? Class12Percentage { get; set; }
    }
}
