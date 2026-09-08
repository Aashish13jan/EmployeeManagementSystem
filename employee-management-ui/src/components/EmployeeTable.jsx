import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  IconButton,
  TextField,
  MenuItem,
  Tooltip,
  Chip,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { MaterialReactTable, useMaterialReactTable } from 'material-react-table';
import { useUserRole } from '../context/UserRoleContext.jsx';

export default function EmployeeTable({
  employees,
  onSearchChange,
  onStatusChange,
  search,
  status,
  onDeleteRequest,
}) {
  const navigate = useNavigate();
  const { canEdit } = useUserRole();

  const columns = useMemo(
    () => [
      { accessorKey: 'employeeCode', header: 'Code', size: 100 },
      { accessorKey: 'fullName', header: 'Name', size: 170 },
      { accessorKey: 'email', header: 'Email', size: 200 },
      { accessorKey: 'phoneNumber', header: 'Phone', size: 130 },
      { accessorKey: 'designation', header: 'Designation', size: 160 },
      {
        accessorKey: 'managerName',
        header: 'Manager',
        size: 150,
        Cell: ({ cell }) => cell.getValue() || '—',
      },
      {
        accessorKey: 'joiningDate',
        header: 'Joining Date',
        size: 120,
        Cell: ({ cell }) => new Date(cell.getValue()).toLocaleDateString(),
      },
      {
        accessorKey: 'status',
        header: 'Status',
        size: 100,
        Cell: ({ cell }) => (
          <Chip
            label={cell.getValue()}
            size="small"
            color={cell.getValue() === 'Active' ? 'success' : 'default'}
            variant="outlined"
          />
        ),
      },
    ],
    []
  );

  const table = useMaterialReactTable({
    columns,
    data: employees,
    enableColumnFilters: false,
    enableGlobalFilter: false, // we drive search via the server-side field above
    enableDensityToggle: false,
    enableFullScreenToggle: false,
    initialState: { pagination: { pageSize: 10, pageIndex: 0 } },
    muiTablePaperProps: { elevation: 0, sx: { border: '1px solid', borderColor: 'divider' } },
    enableRowActions: true,
    positionActionsColumn: 'last',
    displayColumnDefOptions: {
      'mrt-row-actions': { header: 'Actions', size: 100 },
    },
    renderRowActions: ({ row }) => (
      <Box sx={{ display: 'flex', gap: 0.5 }}>
        <Tooltip title={canEdit ? 'Edit' : 'View'}>
          <IconButton
            size="small"
            onClick={() => navigate(`/employees/edit/${row.original.employeeId}`)}
          >
            <EditIcon fontSize="small" />
          </IconButton>
        </Tooltip>
        {canEdit && (
          <Tooltip title="Delete">
            <IconButton size="small" color="error" onClick={() => onDeleteRequest(row.original)}>
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        )}
      </Box>
    ),
    // MRT exposes a single custom-actions slot for the top toolbar, so the
    // search/status filters and the Add button both render here, spaced apart.
    renderTopToolbarCustomActions: () => (
      <Box
        sx={{
          display: 'flex',
          gap: 1.5,
          alignItems: 'center',
          justifyContent: 'space-between',
          width: '100%',
          py: 1,
        }}
      >
        <Box sx={{ display: 'flex', gap: 1.5 }}>
          <TextField
            size="small"
            label="Search"
            placeholder="Name, email, code..."
            value={search}
            onChange={(e) => onSearchChange(e.target.value)}
            sx={{ width: 240 }}
          />
          <TextField
            size="small"
            select
            label="Status"
            value={status}
            onChange={(e) => onStatusChange(e.target.value)}
            sx={{ width: 140 }}
          >
            <MenuItem value="">All</MenuItem>
            <MenuItem value="Active">Active</MenuItem>
            <MenuItem value="Inactive">Inactive</MenuItem>
          </TextField>
        </Box>
        {canEdit && (
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => navigate('/employees/add')}
          >
            Add New Employee
          </Button>
        )}
      </Box>
    ),
  });

  return <MaterialReactTable table={table} />;
}
