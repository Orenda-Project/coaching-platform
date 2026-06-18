import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function PunjabScheduler() {
  const navigate = useNavigate();
  useEffect(() => { navigate('/observation-scheduler', { replace: true }); }, [navigate]);
  return null;
}
