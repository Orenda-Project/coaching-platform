// Canonical render-with-providers helper for component/hook tests.
// Wraps in: QueryClient, MemoryRouter, AuthProvider mock.
//
// Usage:
//   import { renderWithProviders } from '@/test/helpers/render';
//   import { mockUseAuth } from '@/test/mocks/auth-context';
//
//   mockUseAuth({ user: { id: 'u-1' }, profile: { persona: 'B' } });
//   renderWithProviders(<Dashboard />, { route: '/dashboard' });

import { ReactElement, ReactNode } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

interface ProviderOptions extends Omit<RenderOptions, 'wrapper'> {
  route?: string;
}

function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  });
}

export function renderWithProviders(ui: ReactElement, options: ProviderOptions = {}) {
  const { route = '/', ...rest } = options;
  const client = makeQueryClient();

  const Wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={[route]}>{children}</MemoryRouter>
    </QueryClientProvider>
  );

  return render(ui, { wrapper: Wrapper, ...rest });
}
