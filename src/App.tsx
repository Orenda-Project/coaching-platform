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
import Onboarding from "./pages/Onboarding";
import Dashboard from "./pages/Dashboard";
import Assessment from "./pages/Assessment";
import TrainingModule from "./pages/TrainingModule";
import Certificate from "./pages/Certificate";
import NotFound from "./pages/NotFound";
import ResetPassword from "./pages/ResetPassword";
import AdminLayout from "./pages/admin/AdminLayout";
import AdminBaselineQuestions from "./pages/admin/AdminBaselineQuestions";
import AdminModules from "./pages/admin/AdminModules";
import AdminModuleUnits from "./pages/admin/AdminModuleUnits";
import AdminUnitContent from "./pages/admin/AdminUnitContent";
import AdminQuizQuestions from "./pages/admin/AdminQuizQuestions";
import AdminSeed from "./pages/admin/AdminSeed";
import ModuleQuiz from "./pages/ModuleQuiz";
import ScenarioFlow from "./pages/ScenarioFlow";
import AdminScenarios from "./pages/admin/AdminScenarios";
import AdminScenarioOptions from "./pages/admin/AdminScenarioOptions";
import AdminRegions from "./pages/admin/AdminRegions";
import AdminAnalytics from "./pages/admin/AdminAnalytics";
import AdminFeedback from "./pages/admin/AdminFeedback";
import Profile from "./pages/Profile";
import ObservationScheduler from "./pages/ObservationScheduler";
import { FeedbackChatbot } from '@/components/feedback/FeedbackChatbot';

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
            <Route path="/onboarding" element={<ProtectedRoute><Onboarding /></ProtectedRoute>} />
            <Route path="/reset-password" element={<ResetPassword />} />
            <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
            <Route path="/profile" element={<ProtectedRoute><Profile /></ProtectedRoute>} />
            <Route path="/assessment/:type" element={<ProtectedRoute><Assessment /></ProtectedRoute>} />
            <Route path="/training/:id" element={<ProtectedRoute><TrainingModule /></ProtectedRoute>} />
            <Route path="/training/:trainingId/scenario" element={<ProtectedRoute><ScenarioFlow /></ProtectedRoute>} />
            <Route path="/module-quiz/:moduleId" element={<ProtectedRoute><ModuleQuiz /></ProtectedRoute>} />
            <Route path="/certificate" element={<ProtectedRoute><Certificate /></ProtectedRoute>} />
            <Route path="/observation-scheduler" element={<ProtectedRoute><ObservationScheduler /></ProtectedRoute>} />
            <Route path="/admin" element={<ProtectedRoute><AdminLayout /></ProtectedRoute>}>
              <Route index element={<AdminAnalytics />} />
              <Route path="analytics" element={<AdminAnalytics />} />
              <Route path="feedback" element={<AdminFeedback />} />
              <Route path="baseline-questions" element={<AdminBaselineQuestions />} />
              <Route path="modules" element={<AdminModules />} />
              <Route path="modules/:moduleId/units" element={<AdminModuleUnits />} />
              <Route path="units/:unitId/content" element={<AdminUnitContent />} />
              <Route path="units/:unitId/scenarios" element={<AdminScenarios />} />
              <Route path="scenarios/:scenarioId/options" element={<AdminScenarioOptions />} />
              <Route path="quiz-questions" element={<AdminQuizQuestions />} />
              <Route path="regions" element={<AdminRegions />} />
              <Route path="seed" element={<AdminSeed />} />
            </Route>
            <Route path="*" element={<NotFound />} />
          </Routes>
          <FeedbackChatbot />
        </AuthProvider>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
