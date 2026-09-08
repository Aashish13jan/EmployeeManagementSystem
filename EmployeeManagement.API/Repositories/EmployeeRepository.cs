using System.Data;
using EmployeeManagement.API.Data;
using EmployeeManagement.API.DTOs;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EmployeeManagement.API.Repositories
{
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly AppDbContext _context;

        public EmployeeRepository(AppDbContext context)
        {
            _context = context;
        }

        // ---------------------------------------------------------------
        // GET ALL (sp_GetActiveEmployees)
        // ---------------------------------------------------------------
        public async Task<IEnumerable<EmployeeListDto>> GetAllEmployeesAsync(
            string? search, string? status, int? designationId)
        {
            var results = new List<EmployeeListDto>();
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_GetActiveEmployees";
                command.CommandType = CommandType.StoredProcedure;

                AddParameter(command, "@Search", search);
                AddParameter(command, "@Status", status);
                AddParameter(command, "@DesignationId", designationId);

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var firstName = reader["FirstName"].ToString() ?? string.Empty;
                    var lastName = reader["LastName"].ToString() ?? string.Empty;

                    results.Add(new EmployeeListDto
                    {
                        EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                        EmployeeCode = reader["EmployeeCode"].ToString() ?? string.Empty,
                        FullName = $"{firstName} {lastName}".Trim(),
                        Email = reader["Email"].ToString() ?? string.Empty,
                        PhoneNumber = reader["PhoneNumber"] as string,
                        Designation = reader["Designation"].ToString() ?? string.Empty,
                        ManagerName = reader["ManagerName"] as string,
                        JoiningDate = Convert.ToDateTime(reader["JoiningDate"]),
                        Status = reader["Status"].ToString() ?? string.Empty
                    });
                }
            }
            finally
            {
                await connection.CloseAsync();
            }

            return results;
        }

        // ---------------------------------------------------------------
        // GET BY ID (sp_GetEmployeeById)
        // ---------------------------------------------------------------
        public async Task<EmployeeDetailDto?> GetEmployeeByIdAsync(int employeeId)
        {
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_GetEmployeeById";
                command.CommandType = CommandType.StoredProcedure;

                AddParameter(command, "@EmployeeId", employeeId);

                await using var reader = await command.ExecuteReaderAsync();

                if (!await reader.ReadAsync())
                {
                    // No matching row - let the caller (service layer) decide
                    // this means "not found". The repository just reports absence.
                    return null;
                }

                return new EmployeeDetailDto
                {
                    EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                    EmployeeCode = reader["EmployeeCode"].ToString() ?? string.Empty,
                    FirstName = reader["FirstName"].ToString() ?? string.Empty,
                    LastName = reader["LastName"].ToString() ?? string.Empty,
                    Email = reader["Email"].ToString() ?? string.Empty,
                    PhoneNumber = reader["PhoneNumber"] as string,
                    DateOfBirth = reader["DateOfBirth"] == DBNull.Value
                        ? null
                        : Convert.ToDateTime(reader["DateOfBirth"]),
                    DesignationId = Convert.ToInt32(reader["DesignationId"]),
                    DesignationTitle = reader["DesignationTitle"].ToString() ?? string.Empty,
                    ManagerId = reader["ManagerId"] == DBNull.Value
                        ? null
                        : Convert.ToInt32(reader["ManagerId"]),
                    ManagerName = reader["ManagerName"] as string,
                    JoiningDate = Convert.ToDateTime(reader["JoiningDate"]),
                    Status = reader["Status"].ToString() ?? string.Empty,
                    Salary = reader["Salary"] == DBNull.Value
                        ? 0
                        : Convert.ToDecimal(reader["Salary"]),
                    Class10SchoolName = reader["Class10SchoolName"] as string,
                    Class10Percentage = reader["Class10Percentage"] == DBNull.Value
                        ? null
                        : Convert.ToDecimal(reader["Class10Percentage"]),
                    Class12SchoolName = reader["Class12SchoolName"] as string,
                    Class12Percentage = reader["Class12Percentage"] == DBNull.Value
                        ? null
                        : Convert.ToDecimal(reader["Class12Percentage"])
                };
            }
            finally
            {
                await connection.CloseAsync();
            }
        }

        // ---------------------------------------------------------------
        // CREATE (sp_CreateEmployee)
        // ---------------------------------------------------------------
        public async Task<int> CreateEmployeeAsync(EmployeeCreateDto employee)
        {
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_CreateEmployee";
                command.CommandType = CommandType.StoredProcedure;

                AddParameter(command, "@EmployeeCode", employee.EmployeeCode);
                AddParameter(command, "@FirstName", employee.FirstName);
                AddParameter(command, "@LastName", employee.LastName);
                AddParameter(command, "@Email", employee.Email);
                AddParameter(command, "@PhoneNumber", employee.PhoneNumber);
                AddParameter(command, "@DateOfBirth", employee.DateOfBirth);
                AddParameter(command, "@DesignationId", employee.DesignationId);
                AddParameter(command, "@ManagerId", employee.ManagerId);
                AddParameter(command, "@JoiningDate", employee.JoiningDate);
                AddParameter(command, "@Status", employee.Status);
                AddParameter(command, "@Salary", employee.Salary);
                AddParameter(command, "@Class10SchoolName", employee.Class10SchoolName);
                AddParameter(command, "@Class10Percentage", employee.Class10Percentage);
                AddParameter(command, "@Class12SchoolName", employee.Class12SchoolName);
                AddParameter(command, "@Class12Percentage", employee.Class12Percentage);

                // sp_CreateEmployee ends with "SELECT @NewEmployeeId AS NewEmployeeId;"
                // ExecuteScalarAsync reads that single value directly.
                var result = await command.ExecuteScalarAsync();
                return Convert.ToInt32(result);
            }
            finally
            {
                await connection.CloseAsync();
            }
        }

        // ---------------------------------------------------------------
        // UPDATE (sp_UpdateEmployee)
        // ---------------------------------------------------------------
        public async Task UpdateEmployeeAsync(int employeeId, EmployeeUpdateDto employee)
        {
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_UpdateEmployee";
                command.CommandType = CommandType.StoredProcedure;

                AddParameter(command, "@EmployeeId", employeeId);
                AddParameter(command, "@EmployeeCode", employee.EmployeeCode);
                AddParameter(command, "@FirstName", employee.FirstName);
                AddParameter(command, "@LastName", employee.LastName);
                AddParameter(command, "@Email", employee.Email);
                AddParameter(command, "@PhoneNumber", employee.PhoneNumber);
                AddParameter(command, "@DateOfBirth", employee.DateOfBirth);
                AddParameter(command, "@DesignationId", employee.DesignationId);
                AddParameter(command, "@ManagerId", employee.ManagerId);
                AddParameter(command, "@JoiningDate", employee.JoiningDate);
                AddParameter(command, "@Status", employee.Status);
                AddParameter(command, "@Salary", employee.Salary);
                AddParameter(command, "@Class10SchoolName", employee.Class10SchoolName);
                AddParameter(command, "@Class10Percentage", employee.Class10Percentage);
                AddParameter(command, "@Class12SchoolName", employee.Class12SchoolName);
                AddParameter(command, "@Class12Percentage", employee.Class12Percentage);

                // sp_UpdateEmployee RAISERRORs on EMPLOYEE_NOT_FOUND / MANAGER_NOT_FOUND /
                // EMPLOYEE_CANNOT_MANAGE_SELF. We deliberately do NOT catch SqlException
                // here - it propagates up so EmployeeService can translate the message
                // into NotFoundException / ValidationException.
                await command.ExecuteNonQueryAsync();
            }
            finally
            {
                await connection.CloseAsync();
            }
        }

        // ---------------------------------------------------------------
        // SOFT DELETE (sp_SoftDeleteEmployee)
        // ---------------------------------------------------------------
        public async Task SoftDeleteEmployeeAsync(int employeeId)
        {
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_SoftDeleteEmployee";
                command.CommandType = CommandType.StoredProcedure;

                AddParameter(command, "@EmployeeId", employeeId);

                // Propagates EMPLOYEE_NOT_FOUND the same way as UpdateEmployeeAsync.
                await command.ExecuteNonQueryAsync();
            }
            finally
            {
                await connection.CloseAsync();
            }
        }

        // ---------------------------------------------------------------
        // DESIGNATIONS (sp_GetDesignations)
        // ---------------------------------------------------------------
        public async Task<IEnumerable<DesignationDto>> GetDesignationsAsync()
        {
            var results = new List<DesignationDto>();
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_GetDesignations";
                command.CommandType = CommandType.StoredProcedure;

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    results.Add(new DesignationDto
                    {
                        DesignationId = Convert.ToInt32(reader["DesignationId"]),
                        Title = reader["Title"].ToString() ?? string.Empty
                    });
                }
            }
            finally
            {
                await connection.CloseAsync();
            }

            return results;
        }

        // ---------------------------------------------------------------
        // MANAGERS (sp_GetManagers)
        // ---------------------------------------------------------------
        public async Task<IEnumerable<ManagerDto>> GetManagersAsync()
        {
            var results = new List<ManagerDto>();
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_GetManagers";
                command.CommandType = CommandType.StoredProcedure;

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    results.Add(new ManagerDto
                    {
                        EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                        FullName = reader["FullName"].ToString() ?? string.Empty
                    });
                }
            }
            finally
            {
                await connection.CloseAsync();
            }

            return results;
        }

        // ---------------------------------------------------------------
        // CURRENT USER ROLE (sp_GetCurrentUserRole)
        // ---------------------------------------------------------------
        public async Task<CurrentUserRoleDto?> GetCurrentUserRoleAsync()
        {
            var connection = _context.Database.GetDbConnection();

            await EnsureOpenAsync(connection);
            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = "dbo.sp_GetCurrentUserRole";
                command.CommandType = CommandType.StoredProcedure;

                // @UserName is left unset - the SP defaults it to NULL, which
                // returns the row flagged IsCurrentUser = 1 (see Phase 2, Section 15).
                await using var reader = await command.ExecuteReaderAsync();

                if (!await reader.ReadAsync())
                {
                    return null;
                }

                return new CurrentUserRoleDto
                {
                    UserRoleId = Convert.ToInt32(reader["UserRoleId"]),
                    UserName = reader["UserName"].ToString() ?? string.Empty,
                    Role = reader["Role"].ToString() ?? string.Empty
                };
            }
            finally
            {
                await connection.CloseAsync();
            }
        }

        // ---------------------------------------------------------------
        // Private helpers
        // ---------------------------------------------------------------
        private static async Task EnsureOpenAsync(IDbConnection connection)
        {
            if (connection.State != ConnectionState.Open)
            {
                await ((SqlConnection)connection).OpenAsync();
            }
        }

        private static void AddParameter(IDbCommand command, string name, object? value)
        {
            var parameter = command.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value ?? DBNull.Value;
            command.Parameters.Add(parameter);
        }
    }
}
