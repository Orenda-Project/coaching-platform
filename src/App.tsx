import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import Index from "./pages/Index";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import Dashboard from "./pages/Dashboard";
import Assessment from "./pages/Assessment";
import TrainingModule from "./pages/TrainingModule";
import Certificate from "./pages/Certificate";
import NotFound from "./pages/NotFound";
import ResetPassword from "./pages/ResetPassword";
import AdminLayout from "./pages/admin/AdminLayout";
import AdminBaselineQuestions from "./pages/admin/AdminBaselineQuestions";
import AdminTrainings from "./pages/admin/AdminTrainings";
import AdminTrainingContent from "./pages/admin/AdminTrainingContent";
import AdminQuizQuestions from "./pages/admin/AdminQuizQuestions";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <AuthProvider>
          <Routes>
            <Route path="/" element={<Index />} />
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Signup />} />
            <Route path="/reset-password" element={<ResetPassword />} />
            <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
            <Route path="/assessment/:type" element={<ProtectedRoute><Assessment /></ProtectedRoute>} />
            <Route path="/training/:id" element={<ProtectedRoute><TrainingModule /></ProtectedRoute>} />
            <Route path="/certificate" element={<ProtectedRoute><Certificate /></ProtectedRoute>} />
            <Route path="/admin" element={<ProtectedRoute><AdminLayout /></ProtectedRoute>}>
              <Route path="baseline-questions" element={<AdminBaselineQuestions />} />
              <Route path="trainings" element={<AdminTrainings />} />
              <Route path="training-content" element={<AdminTrainingContent />} />
              <Route path="quiz-questions" element={<AdminQuizQuestions />} />
            </Route>
            <Route path="*" element={<NotFound />} />
          </Routes>
        </AuthProvider>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
