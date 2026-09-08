using System.ComponentModel.DataAnnotations;

namespace EmployeeManagement.API.Models
{
    public class UserRole
    {
        public int UserRoleId { get; set; }

        [Required]
        [MaxLength(100)]
        public string UserName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Role { get; set; } = string.Empty;

        public bool IsCurrentUser { get; set; }

        public DateTime CreatedDate { get; set; }
    }
}
