import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Box, Typography, IconButton, Snackbar, Alert } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import {
  getEmployeeById,
  getDesignations,
  getManagers,
  updateEmployee,
  extractErrorMessage,
} from '../api/employeeApi.js';
import EmployeeForm from '../components/EmployeeForm.jsx';
import LoadingIndicator from '../components/LoadingIndicator.jsx';
import ErrorMessage from '../components/ErrorMessage.jsx';
import { useUserRole } from '../context/UserRoleContext.jsx';

// Maps the API's EmployeeDetailDto shape into the flat form shape EmployeeForm expects.
function toFormValues(dto) {
  return {
    employeeCode: dto.employeeCode,
    firstName: dto.firstName,
    lastName: dto.lastName,
    email: dto.email,
    phoneNumber: dto.phoneNumber || '',
    dateOfBirth: dto.dateOfBirth ? dto.dateOfBirth.substring(0, 10) : '',
    designationId: dto.designationId,
    managerId: dto.managerId || '',
    joiningDate: dto.joiningDate ? dto.joiningDate.substring(0, 10) : '',
    status: dto.status,
    salary: dto.salary,
    class10SchoolName: dto.class10SchoolName || '',
    class10Percentage: dto.class10Percentage ?? '',
    class12SchoolName: dto.class12SchoolName || '',
    class12Percentage: dto.class12Percentage ?? '',
  };
}

export default function EditEmployeePage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { canEdit } = useUserRole();

  const [initialValues, setInitialValues] = useState(null);
  const [designations, setDesignations] = useState([]);
  const [managers, setManagers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '' });

  useEffect(() => {
    setLoading(true);
    setError(null);
    Promise.all([getEmployeeById(id), getDesignations(), getManagers()])
      .then(([employee, designationList, managerList]) => {
        setInitialValues(toFormValues(employee));
        setDesignations(designationList);
        setManagers(managerList);
      })
      .catch((err) => setError(extractErrorMessage(err)))
      .finally(() => setLoading(false));
  }, [id]);

  function handleSubmit(payload) {
    setSubmitting(true);
    updateEmployee(id, payload)
      .then(() => {
        navigate('/employees', { state: { flashMessage: 'Employee updated successfully.' } });
      })
      .catch((err) => {
        setSnackbar({ open: true, message: extractErrorMessage(err) });
      })
      .finally(() => setSubmitting(false));
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
        <IconButton onClick={() => navigate('/employees')} sx={{ mr: 1 }}>
          <ArrowBackIcon />
        </IconButton>
        <Typography variant="h5">{canEdit ? 'Edit Employee' : 'Employee Details'}</Typography>
      </Box>

      {loading && <LoadingIndicator label="Loading employee..." />}
      {error && <ErrorMessage message={error} />}

      {!loading && !error && initialValues && (
        <EmployeeForm
          initialValues={initialValues}
          designations={designations}
          managers={managers}
          currentEmployeeId={id}
          readOnly={!canEdit}
          submitting={submitting}
          onSubmit={handleSubmit}
          submitLabel="Save Changes"
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
