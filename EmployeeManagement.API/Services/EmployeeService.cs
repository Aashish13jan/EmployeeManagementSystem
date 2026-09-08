using EmployeeManagement.API.DTOs;
using EmployeeManagement.API.Exceptions;
using EmployeeManagement.API.Repositories;
using Microsoft.Data.SqlClient;

namespace EmployeeManagement.API.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly IEmployeeRepository _employeeRepository;

        public EmployeeService(IEmployeeRepository employeeRepository)
        {
            _employeeRepository = employeeRepository;
        }

        // -----------------------------------------------------------------
        // GET ALL
        // -----------------------------------------------------------------
        public async Task<IEnumerable<EmployeeListDto>> GetAllEmployeesAsync(
            string? search, string? status, int? designationId)
        {
            // No business rules needed for a list/search query -
            // just pass through to the repository.
            return await _employeeRepository.GetAllEmployeesAsync(search, status, designationId);
        }

        // -----------------------------------------------------------------
        // GET BY ID
        // -----------------------------------------------------------------
        public async Task<EmployeeDetailDto> GetEmployeeByIdAsync(int employeeId)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(employeeId);

            if (employee is null)
            {
                throw new NotFoundException($"Employee with ID {employeeId} was not found.");
            }

            return employee;
        }

        // -----------------------------------------------------------------
        // CREATE
        // -----------------------------------------------------------------
        public async Task<int> CreateEmployeeAsync(EmployeeCreateDto employee)
        {
            try
            {
                return await _employeeRepository.CreateEmployeeAsync(employee);
            }
            catch (SqlException ex) when (ex.Message.Contains("MANAGER_NOT_FOUND"))
            {
                // sp_CreateEmployee validates the ManagerId itself (Phase 2 patch).
                // Translate its raised error into a proper 400-mapped exception.
                throw new ValidationException(
                    "The selected manager does not exist or has been removed.");
            }
        }

        // -----------------------------------------------------------------
        // UPDATE
        // -----------------------------------------------------------------
        public async Task UpdateEmployeeAsync(int employeeId, EmployeeUpdateDto employee)
        {
            // Fail-fast business rule check before hitting the database.
            // sp_UpdateEmployee enforces this too (defense in depth), but
            // catching it here avoids an unnecessary round trip.
            if (employee.ManagerId.HasValue && employee.ManagerId.Value == employeeId)
            {
                throw new ValidationException("An employee cannot be their own manager.");
            }

            try
            {
                await _employeeRepository.UpdateEmployeeAsync(employeeId, employee);
            }
            catch (SqlException ex) when (ex.Message.Contains("EMPLOYEE_NOT_FOUND"))
            {
                throw new NotFoundException($"Employee with ID {employeeId} was not found.");
            }
            catch (SqlException ex) when (ex.Message.Contains("MANAGER_NOT_FOUND"))
            {
                throw new ValidationException(
                    "The selected manager does not exist or has been removed.");
            }
            catch (SqlException ex) when (ex.Message.Contains("EMPLOYEE_CANNOT_MANAGE_SELF"))
            {
                throw new ValidationException("An employee cannot be their own manager.");
            }
        }

        // -----------------------------------------------------------------
        // SOFT DELETE
        // -----------------------------------------------------------------
        public async Task SoftDeleteEmployeeAsync(int employeeId)
        {
            try
            {
                await _employeeRepository.SoftDeleteEmployeeAsync(employeeId);
            }
            catch (SqlException ex) when (ex.Message.Contains("EMPLOYEE_NOT_FOUND"))
            {
                throw new NotFoundException($"Employee with ID {employeeId} was not found.");
            }
        }

        // -----------------------------------------------------------------
        // DESIGNATIONS
        // -----------------------------------------------------------------
        public async Task<IEnumerable<DesignationDto>> GetDesignationsAsync()
        {
            return await _employeeRepository.GetDesignationsAsync();
        }

        // -----------------------------------------------------------------
        // MANAGERS
        // -----------------------------------------------------------------
        public async Task<IEnumerable<ManagerDto>> GetManagersAsync()
        {
            return await _employeeRepository.GetManagersAsync();
        }

        // -----------------------------------------------------------------
        // CURRENT USER ROLE
        // -----------------------------------------------------------------
        public async Task<CurrentUserRoleDto> GetCurrentUserRoleAsync()
        {
            var role = await _employeeRepository.GetCurrentUserRoleAsync();

            if (role is null)
            {
                throw new NotFoundException(
                    "No current user role is configured. Check the UserRoles table.");
            }

            return role;
        }
    }
}
