import { Routes, Route, Navigate } from 'react-router-dom';
import { AppBar, Toolbar, Typography, Container, Box, Chip } from '@mui/material';
import BusinessIcon from '@mui/icons-material/Business';
import EmployeeListPage from './pages/EmployeeListPage.jsx';
import AddEmployeePage from './pages/AddEmployeePage.jsx';
import EditEmployeePage from './pages/EditEmployeePage.jsx';
import { useUserRole } from './context/UserRoleContext.jsx';

export default function App() {
  const { role, loading } = useUserRole();

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'background.default' }}>
      <AppBar position="static" color="primary">
        <Toolbar>
          <BusinessIcon sx={{ mr: 1.5 }} />
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            Employee Management System
          </Typography>
          {!loading && role && (
            <Chip
              label={role}
              size="small"
              sx={{ bgcolor: 'rgba(255,255,255,0.15)', color: 'white' }}
            />
          )}
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Routes>
          <Route path="/" element={<Navigate to="/employees" replace />} />
          <Route path="/employees" element={<EmployeeListPage />} />
          <Route path="/employees/add" element={<AddEmployeePage />} />
          <Route path="/employees/edit/:id" element={<EditEmployeePage />} />
          <Route path="*" element={<Navigate to="/employees" replace />} />
        </Routes>
      </Container>
    </Box>
  );
}
