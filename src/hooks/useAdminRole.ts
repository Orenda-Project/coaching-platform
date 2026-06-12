import { useEffect, useState } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { authApiClient } from "@/lib/apiClients/authApiClient";

export function useAdminRole() {
  const { user } = useAuth();
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) { setLoading(false); return; }
    authApiClient.getRoles(user.id)
      .then((roles) => {
        setIsAdmin(roles.includes("admin"));
        setLoading(false);
      })
      .catch(() => {
        setLoading(false);
      });
  }, [user]);

  return { isAdmin, loading };
}
