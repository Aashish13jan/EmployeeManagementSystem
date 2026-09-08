namespace EmployeeManagement.API.DTOs
{
    public class CurrentUserRoleDto
    {
        public int UserRoleId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}
