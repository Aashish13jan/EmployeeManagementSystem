using EmployeeManagement.API.DTOs;

namespace EmployeeManagement.API.Repositories
{
    public interface IEmployeeRepository
    {
        Task<IEnumerable<EmployeeListDto>> GetAllEmployeesAsync(
            string? search, string? status, int? designationId);

        Task<EmployeeDetailDto?> GetEmployeeByIdAsync(int employeeId);

        Task<int> CreateEmployeeAsync(EmployeeCreateDto employee);

        Task UpdateEmployeeAsync(int employeeId, EmployeeUpdateDto employee);

        Task SoftDeleteEmployeeAsync(int employeeId);

        Task<IEnumerable<DesignationDto>> GetDesignationsAsync();

        Task<IEnumerable<ManagerDto>> GetManagersAsync();

        Task<CurrentUserRoleDto?> GetCurrentUserRoleAsync();
    }
}
