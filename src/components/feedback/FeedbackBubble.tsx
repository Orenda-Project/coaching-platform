import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type FeedbackBubbleProps = {
  variant: 'system' | 'user';
  children: ReactNode;
};

export function FeedbackBubble({ variant, children }: FeedbackBubbleProps) {
  return (
    <div
      className={cn(
        'flex w-full mb-3',
        variant === 'system' ? 'justify-start' : 'justify-end',
      )}
    >
      <div
        className={cn(
          'max-w-[85%] rounded-2xl px-4 py-2 text-sm',
          variant === 'system'
            ? 'bg-muted text-foreground rounded-bl-sm'
            : 'bg-primary text-primary-foreground rounded-br-sm',
        )}
      >
        {children}
      </div>
    </div>
  );
}
