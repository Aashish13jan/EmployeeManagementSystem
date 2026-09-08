import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Typography, IconButton, Snackbar, Alert } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import {
  getDesignations,
  getManagers,
  createEmployee,
  extractErrorMessage,
} from '../api/employeeApi.js';
import EmployeeForm from '../components/EmployeeForm.jsx';
import LoadingIndicator from '../components/LoadingIndicator.jsx';
import ErrorMessage from '../components/ErrorMessage.jsx';
import { useUserRole } from '../context/UserRoleContext.jsx';

export default function AddEmployeePage() {
  const navigate = useNavigate();
  const { canEdit, loading: roleLoading } = useUserRole();

  const [designations, setDesignations] = useState([]);
  const [managers, setManagers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '' });

  useEffect(() => {
    setLoading(true);
    Promise.all([getDesignations(), getManagers()])
      .then(([designationList, managerList]) => {
        setDesignations(designationList);
        setManagers(managerList);
      })
      .catch((err) => setError(extractErrorMessage(err)))
      .finally(() => setLoading(false));
  }, []);

  function handleSubmit(payload) {
    setSubmitting(true);
    createEmployee(payload)
      .then(() => {
        navigate('/employees', { state: { flashMessage: 'Employee created successfully.' } });
      })
      .catch((err) => {
        setSnackbar({ open: true, message: extractErrorMessage(err) });
      })
      .finally(() => setSubmitting(false));
  }

  // Guard against a User role reaching this page directly via URL - the
  // list page already hides the "Add New Employee" button for them.
  if (!roleLoading && !canEdit) {
    return (
      <Box sx={{ py: 6, textAlign: 'center' }}>
        <Typography color="text.secondary">
          You do not have permission to add employees.
        </Typography>
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
        <IconButton onClick={() => navigate('/employees')} sx={{ mr: 1 }}>
          <ArrowBackIcon />
        </IconButton>
        <Typography variant="h5">Add New Employee</Typography>
      </Box>

      {(loading || roleLoading) && <LoadingIndicator label="Loading form options..." />}
      {error && <ErrorMessage message={error} />}

      {!loading && !roleLoading && !error && (
        <EmployeeForm
          designations={designations}
          managers={managers}
          submitting={submitting}
          onSubmit={handleSubmit}
          submitLabel="Create Employee"
        />
      )}

      <Snackbar
        open={snackbar.open}
        autoHideDuration={5000}
        onClose={() => setSnackbar({ open: false, message: '' })}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert severity="error" variant="filled">
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
