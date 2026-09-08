import axios from 'axios';

// Falls back to a sensible local dev default if VITE_API_BASE_URL isn't set,
// but you should create a .env file (copy .env.example) pointing at whatever
// port "dotnet run" actually prints for your machine.
const baseURL = import.meta.env.VITE_API_BASE_URL || 'https://localhost:7001/api';

const apiClient = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// ---------------------------------------------------------------------------
// Employees
// ---------------------------------------------------------------------------

export function getEmployees({ search, status, designationId } = {}) {
  return apiClient
    .get('/employees', { params: { search, status, designationId } })
    .then((res) => res.data);
}

export function getEmployeeById(id) {
  return apiClient.get(`/employees/${id}`).then((res) => res.data);
}

export function createEmployee(employee) {
  return apiClient.post('/employees', employee).then((res) => res.data);
}

export function updateEmployee(id, employee) {
  return apiClient.put(`/employees/${id}`, employee).then((res) => res.data);
}

export function deleteEmployee(id) {
  return apiClient.delete(`/employees/${id}`).then((res) => res.data);
}

// ---------------------------------------------------------------------------
// Lookups
// ---------------------------------------------------------------------------

export function getDesignations() {
  return apiClient.get('/designations').then((res) => res.data);
}

export function getManagers() {
  return apiClient.get('/employees/managers').then((res) => res.data);
}

export function getCurrentUserRole() {
  return apiClient.get('/userrole/current').then((res) => res.data);
}

// ---------------------------------------------------------------------------
// Shared error-message helper
// ---------------------------------------------------------------------------

// The backend's ExceptionHandlingMiddleware returns { statusCode, message }
// for NotFoundException/ValidationException, and [ApiController]'s built-in
// model validation returns a ValidationProblemDetails shape with an "errors"
// object. This normalizes both into a single readable string for the UI.
export function extractErrorMessage(error) {
  const data = error?.response?.data;

  if (!data) {
    return error?.message || 'Something went wrong. Please try again.';
  }

  if (data.message) {
    return data.message;
  }

  if (data.errors) {
    const firstField = Object.keys(data.errors)[0];
    const firstMessage = data.errors[firstField]?.[0];
    if (firstMessage) {
      return firstMessage;
    }
  }

  return 'Something went wrong. Please try again.';
}

export default apiClient;
