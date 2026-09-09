import axios from 'axios';

// Get the API URL from the Vercel environment variable.
// Falls back to localhost when running the project locally.
const baseURL =
    import.meta.env.VITE_API_BASE_URL || 'https://localhost:7001/api';

// Temporary check — open the browser Console (F12) to verify the URL.
console.log('API Base URL:', baseURL);

const apiClient = axios.create({
    baseURL: baseURL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// ---------------------------------------------------------------------------
// Employees
// ---------------------------------------------------------------------------

export function getEmployees({ search, status, designationId } = {}) {
    return apiClient
        .get('/employees', {
            params: {
                search,
                status,
                designationId,
            },
        })
        .then((res) => res.data);
}

export function getEmployeeById(id) {
    return apiClient
        .get(`/employees/${id}`)
        .then((res) => res.data);
}

export function createEmployee(employee) {
    return apiClient
        .post('/employees', employee)
        .then((res) => res.data);
}

export function updateEmployee(id, employee) {
    return apiClient
        .put(`/employees/${id}`, employee)
        .then((res) => res.data);
}

export function deleteEmployee(id) {
    return apiClient
        .delete(`/employees/${id}`)
        .then((res) => res.data);
}

// ---------------------------------------------------------------------------
// Lookups
// ---------------------------------------------------------------------------

export function getDesignations() {
    return apiClient
        .get('/designations')
        .then((res) => res.data);
}

export function getManagers() {
    return apiClient
        .get('/employees/managers')
        .then((res) => res.data);
}

export function getCurrentUserRole() {
    return apiClient
        .get('/userrole/current')
        .then((res) => res.data);
}

// ---------------------------------------------------------------------------
// Shared error-message helper
// ---------------------------------------------------------------------------

export function extractErrorMessage(error) {
    const data = error?.response?.data;

    console.error('API Error:', error);

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