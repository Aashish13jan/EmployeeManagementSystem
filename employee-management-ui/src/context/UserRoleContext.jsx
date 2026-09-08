import { createContext, useContext, useEffect, useState } from 'react';
import { getCurrentUserRole } from '../api/employeeApi.js';

const UserRoleContext = createContext(null);

export function UserRoleProvider({ children }) {
  const [role, setRole] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getCurrentUserRole()
      .then((data) => setRole(data.role))
      .catch(() => setRole('User')) // fail safe: treat as read-only if the lookup fails
      .finally(() => setLoading(false));
  }, []);

  const canEdit = role === 'Admin' || role === 'Manager';

  return (
    <UserRoleContext.Provider value={{ role, canEdit, loading }}>
      {children}
    </UserRoleContext.Provider>
  );
}

export function useUserRole() {
  return useContext(UserRoleContext);
}
