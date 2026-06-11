import { useEffect, useState } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { authApiClient } from "@/lib/apiClients/authApiClient";

export function useCoachRole() {
  const { user } = useAuth();
  const [isCoach, setIsCoach] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) { setLoading(false); return; }
    authApiClient.getRoles(user.id)
      .then((roles) => {
        setIsCoach(roles.includes("coach"));
        setLoading(false);
      })
      .catch(() => {
        setLoading(false);
      });
  }, [user]);

  return { isCoach, loading };
}
