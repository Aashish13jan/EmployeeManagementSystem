import { createTheme } from '@mui/material/styles';

// Deliberately restrained palette and defaults - this is an internal
// business tool, not a marketing site. No gradients, minimal shadows.
const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#2c5f8a',
    },
    background: {
      default: '#f4f6f8',
    },
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      'Helvetica',
      'Arial',
      'sans-serif',
    ].join(','),
    h5: {
      fontWeight: 600,
    },
    h6: {
      fontWeight: 600,
    },
  },
  shape: {
    borderRadius: 6,
  },
  components: {
    MuiButton: {
      defaultProps: {
        disableElevation: true,
      },
    },
    MuiAppBar: {
      defaultProps: {
        elevation: 0,
      },
    },
  },
});

export default theme;
