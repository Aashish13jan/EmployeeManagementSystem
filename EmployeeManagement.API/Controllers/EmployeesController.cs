using EmployeeManagement.API.DTOs;
using EmployeeManagement.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace EmployeeManagement.API.Controllers
{
    // Attribute routing with explicit paths on each action (rather than a single
    // controller-level [Route("api/employees")]) because this controller also
    // serves /api/designations and /api/userrole/current - kept in one controller
    // per the project's "don't create unnecessary layers" guidance, since these
    // are small, closely related lookups rather than full resources of their own.
    [ApiController]
    public class EmployeesController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public EmployeesController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        // GET /api/employees?search=&status=&designationId=
        [HttpGet("api/employees")]
        [ProducesResponseType(typeof(IEnumerable<EmployeeListDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<EmployeeListDto>>> GetAll(
            [FromQuery] string? search,
            [FromQuery] string? status,
            [FromQuery] int? designationId)
        {
            var employees = await _employeeService.GetAllEmployeesAsync(search, status, designationId);
            return Ok(employees);
        }

        // GET /api/employees/{id}
        [HttpGet("api/employees/{id:int}")]
        [ProducesResponseType(typeof(EmployeeDetailDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<EmployeeDetailDto>> GetById(int id)
        {
            // NotFoundException thrown by the service is caught by
            // ExceptionHandlingMiddleware and turned into a 404 - no
            // try/catch or null-check needed here.
            var employee = await _employeeService.GetEmployeeByIdAsync(id);
            return Ok(employee);
        }

        // POST /api/employees
        [HttpPost("api/employees")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult> Create([FromBody] EmployeeCreateDto employeeDto)
        {
            // [ApiController] automatically returns 400 with validation details
            // if Data Annotation checks on EmployeeCreateDto fail - this method
            // body only runs once the DTO is already known to be well-formed.
            var newEmployeeId = await _employeeService.CreateEmployeeAsync(employeeDto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = newEmployeeId },
                new { employeeId = newEmployeeId });
        }

        // PUT /api/employees/{id}
        [HttpPut("api/employees/{id:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Update(int id, [FromBody] EmployeeUpdateDto employeeDto)
        {
            await _employeeService.UpdateEmployeeAsync(id, employeeDto);
            return Ok(new { message = "Employee updated successfully." });
        }

        // DELETE /api/employees/{id}  (soft delete)
        [HttpDelete("api/employees/{id:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(int id)
        {
            await _employeeService.SoftDeleteEmployeeAsync(id);
            return Ok(new { message = "Employee deleted successfully." });
        }

        // GET /api/designations
        [HttpGet("api/designations")]
        [ProducesResponseType(typeof(IEnumerable<DesignationDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<DesignationDto>>> GetDesignations()
        {
            var designations = await _employeeService.GetDesignationsAsync();
            return Ok(designations);
        }

        // GET /api/employees/managers
        [HttpGet("api/employees/managers")]
        [ProducesResponseType(typeof(IEnumerable<ManagerDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ManagerDto>>> GetManagers()
        {
            var managers = await _employeeService.GetManagersAsync();
            return Ok(managers);
        }

        // GET /api/userrole/current
        [HttpGet("api/userrole/current")]
        [ProducesResponseType(typeof(CurrentUserRoleDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<CurrentUserRoleDto>> GetCurrentUserRole()
        {
            var role = await _employeeService.GetCurrentUserRoleAsync();
            return Ok(role);
        }
    }
}
