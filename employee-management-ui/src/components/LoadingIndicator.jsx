import { Box, CircularProgress, Typography } from '@mui/material';

export default function LoadingIndicator({ label = 'Loading...' }) {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        py: 6,
      }}
    >
      <CircularProgress size={32} />
      <Typography variant="body2" color="text.secondary" sx={{ mt: 1.5 }}>
        {label}
      </Typography>
    </Box>
  );
}
