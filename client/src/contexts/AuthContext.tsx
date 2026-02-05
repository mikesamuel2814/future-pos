import { createContext, useContext, ReactNode } from "react";
import { useQuery } from "@tanstack/react-query";

interface AuthUser {
  id: string;
  username: string;
  fullName: string;
  email: string | null;
  role: string;
  permissions?: string[];
}

interface AuthContextType {
  user: AuthUser | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  // Query user from server - this relies on session cookies
  const { data: user, isLoading } = useQuery<AuthUser>({
    queryKey: ["/api/auth/session"],
    retry: false,
    // Always refetch on mount to get fresh session data
    refetchOnMount: true,
    refetchOnWindowFocus: true,
    // Keep data fresh for 1 minute
    staleTime: 60 * 1000,
  });

  const isAuthenticated = !!user;

  return (
    <AuthContext.Provider value={{ user: user || null, isLoading, isAuthenticated }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

