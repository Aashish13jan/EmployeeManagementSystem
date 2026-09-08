import { useState } from 'react';
import {
  Box,
  Paper,
  Grid,
  TextField,
  MenuItem,
  Typography,
  Divider,
  Button,
  Stack,
} from '@mui/material';

const emptyForm = {
  employeeCode: '',
  firstName: '',
  lastName: '',
  email: '',
  phoneNumber: '',
  dateOfBirth: '',
  designationId: '',
  managerId: '',
  joiningDate: '',
  status: 'Active',
  salary: '',
  class10SchoolName: '',
  class10Percentage: '',
  class12SchoolName: '',
  class12Percentage: '',
};

// Shared by AddEmployeePage and EditEmployeePage. initialValues (when editing)
// is expected to already be shaped like emptyForm above - the pages are
// responsible for mapping the API's EmployeeDetailDto into this shape.
export default function EmployeeForm({
  initialValues,
  designations,
  managers,
  currentEmployeeId, // used to exclude self from the manager dropdown when editing
  readOnly,
  submitting,
  onSubmit,
  submitLabel = 'Save',
}) {
  const [form, setForm] = useState(initialValues || emptyForm);
  const [errors, setErrors] = useState({});

  const handleChange = (field) => (e) => {
    setForm((prev) => ({ ...prev, [field]: e.target.value }));
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  function validate() {
    const next = {};

    if (!form.employeeCode.trim()) next.employeeCode = 'Employee code is required.';
    if (!form.firstName.trim()) next.firstName = 'First name is required.';
    if (!form.lastName.trim()) next.lastName = 'Last name is required.';

    if (!form.email.trim()) {
      next.email = 'Email is required.';
    } else if (!/^\S+@\S+\.\S+$/.test(form.email)) {
      next.email = 'Enter a valid email address.';
    }

    if (form.phoneNumber && !/^[0-9+\-\s()]{7,20}$/.test(form.phoneNumber)) {
      next.phoneNumber = 'Enter a valid phone number.';
    }

    if (!form.designationId) next.designationId = 'Designation is required.';
    if (!form.joiningDate) next.joiningDate = 'Joining date is required.';

    if (form.managerId && currentEmployeeId && Number(form.managerId) === Number(currentEmployeeId)) {
      next.managerId = 'An employee cannot be their own manager.';
    }

    if (form.salary === '' || form.salary === null) {
      next.salary = 'Salary is required.';
    } else if (Number(form.salary) < 0) {
      next.salary = 'Salary cannot be negative.';
    }

    if (form.class10Percentage !== '' && (form.class10Percentage < 0 || form.class10Percentage > 100)) {
      next.class10Percentage = 'Must be between 0 and 100.';
    }
    if (form.class12Percentage !== '' && (form.class12Percentage < 0 || form.class12Percentage > 100)) {
      next.class12Percentage = 'Must be between 0 and 100.';
    }

    setErrors(next);
    return Object.keys(next).length === 0;
  }

  function handleSubmit(e) {
    e.preventDefault();
    if (!validate()) return;

    onSubmit({
      employeeCode: form.employeeCode.trim(),
      firstName: form.firstName.trim(),
      lastName: form.lastName.trim(),
      email: form.email.trim(),
      phoneNumber: form.phoneNumber || null,
      dateOfBirth: form.dateOfBirth || null,
      designationId: Number(form.designationId),
      managerId: form.managerId ? Number(form.managerId) : null,
      joiningDate: form.joiningDate,
      status: form.status,
      salary: Number(form.salary),
      class10SchoolName: form.class10SchoolName || null,
      class10Percentage: form.class10Percentage === '' ? null : Number(form.class10Percentage),
      class12SchoolName: form.class12SchoolName || null,
      class12Percentage: form.class12Percentage === '' ? null : Number(form.class12Percentage),
    });
  }

  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Personal Details
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="First Name"
              value={form.firstName}
              onChange={handleChange('firstName')}
              error={!!errors.firstName}
              helperText={errors.firstName}
              disabled={readOnly}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Last Name"
              value={form.lastName}
              onChange={handleChange('lastName')}
              error={!!errors.lastName}
              helperText={errors.lastName}
              disabled={readOnly}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Email"
              type="email"
              value={form.email}
              onChange={handleChange('email')}
              error={!!errors.email}
              helperText={errors.email}
              disabled={readOnly}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Phone Number"
              value={form.phoneNumber}
              onChange={handleChange('phoneNumber')}
              error={!!errors.phoneNumber}
              helperText={errors.phoneNumber}
              disabled={readOnly}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Date of Birth"
              type="date"
              InputLabelProps={{ shrink: true }}
              value={form.dateOfBirth}
              onChange={handleChange('dateOfBirth')}
              disabled={readOnly}
            />
          </Grid>
        </Grid>
      </Paper>

      <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Employment Details
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Employee Code"
              value={form.employeeCode}
              onChange={handleChange('employeeCode')}
              error={!!errors.employeeCode}
              helperText={errors.employeeCode}
              disabled={readOnly}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              select
              label="Designation"
              value={form.designationId}
              onChange={handleChange('designationId')}
              error={!!errors.designationId}
              helperText={errors.designationId}
              disabled={readOnly}
              required
            >
              {designations.map((d) => (
                <MenuItem key={d.designationId} value={d.designationId}>
                  {d.title}
                </MenuItem>
              ))}
            </TextField>
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              select
              label="Manager"
              value={form.managerId}
              onChange={handleChange('managerId')}
              error={!!errors.managerId}
              helperText={errors.managerId}
              disabled={readOnly}
            >
              <MenuItem value="">None</MenuItem>
              {managers
                .filter((m) => !currentEmployeeId || m.employeeId !== Number(currentEmployeeId))
                .map((m) => (
                  <MenuItem key={m.employeeId} value={m.employeeId}>
                    {m.fullName}
                  </MenuItem>
                ))}
            </TextField>
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Joining Date"
              type="date"
              InputLabelProps={{ shrink: true }}
              value={form.joiningDate}
              onChange={handleChange('joiningDate')}
              error={!!errors.joiningDate}
              helperText={errors.joiningDate}
              disabled={readOnly}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              select
              label="Status"
              value={form.status}
              onChange={handleChange('status')}
              disabled={readOnly}
            >
              <MenuItem value="Active">Active</MenuItem>
              <MenuItem value="Inactive">Inactive</MenuItem>
            </TextField>
          </Grid>
        </Grid>
      </Paper>

      <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Compensation Details
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Salary"
              type="number"
              value={form.salary}
              onChange={handleChange('salary')}
              error={!!errors.salary}
              helperText={errors.salary}
              disabled={readOnly}
              required
            />
          </Grid>
        </Grid>
      </Paper>

      <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Education Details
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Class 10 School"
              value={form.class10SchoolName}
              onChange={handleChange('class10SchoolName')}
              disabled={readOnly}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Class 10 Percentage"
              type="number"
              value={form.class10Percentage}
              onChange={handleChange('class10Percentage')}
              error={!!errors.class10Percentage}
              helperText={errors.class10Percentage}
              disabled={readOnly}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Class 12 School"
              value={form.class12SchoolName}
              onChange={handleChange('class12SchoolName')}
              disabled={readOnly}
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              fullWidth
              label="Class 12 Percentage"
              type="number"
              value={form.class12Percentage}
              onChange={handleChange('class12Percentage')}
              error={!!errors.class12Percentage}
              helperText={errors.class12Percentage}
              disabled={readOnly}
            />
          </Grid>
        </Grid>
      </Paper>

      {!readOnly && (
        <Stack direction="row" spacing={2} justifyContent="flex-end">
          <Button type="submit" variant="contained" disabled={submitting}>
            {submitting ? 'Saving...' : submitLabel}
          </Button>
        </Stack>
      )}
    </Box>
  );
}
