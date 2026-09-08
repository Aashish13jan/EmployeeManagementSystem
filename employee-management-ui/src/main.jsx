import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme.js';
import App from './App.jsx';
import { UserRoleProvider } from './context/UserRoleContext.jsx';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <UserRoleProvider>
          <App />
        </UserRoleProvider>
      </BrowserRouter>
    </ThemeProvider>
  </React.StrictMode>
);
