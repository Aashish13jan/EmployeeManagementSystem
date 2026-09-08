import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Box, Typography, Snackbar, Alert } from '@mui/material';
import { getEmployees, deleteEmployee, extractErrorMessage } from '../api/employeeApi.js';
import EmployeeTable from '../components/EmployeeTable.jsx';
import LoadingIndicator from '../components/LoadingIndicator.jsx';
import ErrorMessage from '../components/ErrorMessage.jsx';
import ConfirmationDialog from '../components/ConfirmationDialog.jsx';

export default function EmployeeListPage() {
  const location = useLocation();
  const navigate = useNavigate();

  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');

  const [deleteTarget, setDeleteTarget] = useState(null);
  const [deleting, setDeleting] = useState(false);

  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  // Add/Edit pages navigate back here with a flash message in route state
  // (e.g. "Employee created successfully.") - show it once, then clear the
  // state so a page refresh doesn't re-show it.
  useEffect(() => {
    if (location.state?.flashMessage) {
      setSnackbar({ open: true, message: location.state.flashMessage, severity: 'success' });
      navigate(location.pathname, { replace: true, state: {} });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchEmployees = useCallback(() => {
    setLoading(true);
    setError(null);
    getEmployees({ search: search || undefined, status: status || undefined })
      .then(setEmployees)
      .catch((err) => setError(extractErrorMessage(err)))
      .finally(() => setLoading(false));
  }, [search, status]);

  useEffect(() => {
    // simple debounce so we don't hit the API on every keystroke
    const timeout = setTimeout(fetchEmployees, 300);
    return () => clearTimeout(timeout);
  }, [fetchEmployees]);

  function handleDeleteConfirm() {
    setDeleting(true);
    deleteEmployee(deleteTarget.employeeId)
      .then(() => {
        setSnackbar({ open: true, message: 'Employee deleted successfully.', severity: 'success' });
        setDeleteTarget(null);
        fetchEmployees();
      })
      .catch((err) => {
        setSnackbar({ open: true, message: extractErrorMessage(err), severity: 'error' });
      })
      .finally(() => setDeleting(false));
  }

  return (
    <Box>
      <Typography variant="h5" sx={{ mb: 2 }}>
        Employees
      </Typography>

      {loading && employees.length === 0 && <LoadingIndicator label="Loading employees..." />}

      {error && <ErrorMessage message={error} onRetry={fetchEmployees} />}

      {!error && !loading && employees.length === 0 && (
        <Box sx={{ py: 6, textAlign: 'center' }}>
          <Typography color="text.secondary">
            No employees found{search || status ? ' for the current filters' : ''}.
          </Typography>
        </Box>
      )}

      {!error && employees.length > 0 && (
        <EmployeeTable
          employees={employees}
          search={search}
          status={status}
          onSearchChange={setSearch}
          onStatusChange={setStatus}
          onDeleteRequest={setDeleteTarget}
        />
      )}

      <ConfirmationDialog
        open={!!deleteTarget}
        title="Delete employee?"
        message={
          deleteTarget
            ? `Are you sure you want to delete ${deleteTarget.fullName}? This can be reversed later by an administrator.`
            : ''
        }
        confirmLabel="Delete"
        confirmColor="error"
        loading={deleting}
        onConfirm={handleDeleteConfirm}
        onCancel={() => setDeleteTarget(null)}
      />

      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar((prev) => ({ ...prev, open: false }))}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert severity={snackbar.severity} variant="filled">
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
