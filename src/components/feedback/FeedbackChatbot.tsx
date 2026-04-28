import { useEffect, useState } from 'react';
import { useLocation, useParams } from 'react-router-dom';
import { MessageCircle, Star } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet';
import { Textarea } from '@/components/ui/textarea';
import { toast } from '@/components/ui/sonner';
import { useAuth } from '@/contexts/AuthContext';
import { useIsMobile } from '@/hooks/use-mobile';
import { useFeedback } from '@/hooks/useFeedback';
import { FeedbackBubble } from './FeedbackBubble';

type Phase = 'greet' | 'category' | 'rating' | 'text' | 'submitting' | 'done';
type Category = 'module' | 'platform' | 'bug' | 'other';

const CATEGORY_OPTIONS: { value: Category; label: string }[] = [
  { value: 'module',   label: 'This module' },
  { value: 'platform', label: 'Platform experience' },
  { value: 'bug',      label: 'Something not working' },
  { value: 'other',    label: 'Other' },
];

const CATEGORY_LABEL: Record<Category, string> = {
  module: 'This module',
  platform: 'Platform experience',
  bug: 'Something not working',
  other: 'Other',
};

const EXCLUDED_PREFIXES = [
  '/assessment/',
  '/module-quiz/',
  '/admin/',
];

function isExcludedPath(pathname: string): boolean {
  if (EXCLUDED_PREFIXES.some((p) => pathname.startsWith(p))) return true;
  // Scenario flow: /training/:trainingId/scenario
  if (/^\/training\/[^/]+\/scenario$/.test(pathname)) return true;
  return false;
}

export function FeedbackChatbot() {
  const { user } = useAuth();
  const location = useLocation();
  const isMobile = useIsMobile();
  const { submit } = useFeedback();
  const params = useParams();

  const trainingIdFromRoute =
    /^\/training\/[^/]+(\/.*)?$/.test(location.pathname) ? params.id ?? null : null;

  const [open, setOpen] = useState(false);
  const [phase, setPhase] = useState<Phase>('greet');
  const [cooldownUntil, setCooldownUntil] = useState<number | null>(null);
  const [now, setNow] = useState(Date.now());

  // Form state — used in later tasks (Category, Rating, Text)
  const [category, setCategory] = useState<Category | ''>('');
  const [rating, setRating] = useState(0);
  const [positive, setPositive] = useState('');
  const [improvement, setImprovement] = useState('');

  const handleSubmit = async () => {
    if (phase === 'submitting') return;
    if (!category || rating === 0) {
      toast.error('Please pick a category and rating');
      return;
    }
    setPhase('submitting');
    const result = await submit({
      category,
      rating,
      positive_feedback: positive,
      improvement_feedback: improvement,
      context_page: location.pathname,
      training_id: trainingIdFromRoute,
    });
    if (result.ok) {
      setPhase('done');
    } else {
      toast.error("Couldn't send feedback. Try again.");
      setPhase('text');
    }
  };

  // Tick the cooldown countdown once per second when active; self-cleans on expiry
  useEffect(() => {
    if (cooldownUntil === null) return;
    if (Date.now() >= cooldownUntil) {
      setCooldownUntil(null);
      return;
    }
    const interval = setInterval(() => {
      const t = Date.now();
      setNow(t);
      if (t >= cooldownUntil) {
        clearInterval(interval);
        setCooldownUntil(null);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [cooldownUntil]);

  // Reset form when sheet closes
  useEffect(() => {
    if (!open) {
      setPhase('greet');
      setCategory('');
      setRating(0);
      setPositive('');
      setImprovement('');
    }
  }, [open]);

  if (!user) return null;
  if (isExcludedPath(location.pathname)) return null;

  const onCooldown = cooldownUntil !== null && now < cooldownUntil;
  const cooldownSecondsLeft = onCooldown
    ? Math.ceil((cooldownUntil! - now) / 1000)
    : 0;

  return (
    <>
      <Button
        type="button"
        size="icon"
        aria-label="Share feedback"
        title={
          onCooldown
            ? `Thanks — you can share more feedback in ${cooldownSecondsLeft}s`
            : 'Share feedback'
        }
        disabled={onCooldown}
        onClick={() => setOpen(true)}
        className="fixed bottom-6 right-6 z-50 h-14 w-14 rounded-full shadow-lg"
      >
        <MessageCircle className="h-6 w-6" />
      </Button>

      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent
          side={isMobile ? 'bottom' : 'right'}
          className={isMobile ? 'h-[80vh] flex flex-col' : 'w-full sm:max-w-md flex flex-col'}
        >
          <SheetHeader>
            <SheetTitle>Share feedback</SheetTitle>
            <SheetDescription className="sr-only">
              Share your experience with the coaching platform
            </SheetDescription>
          </SheetHeader>

          <div
            className="flex-1 overflow-y-auto py-4"
            role="log"
            aria-live="polite"
            aria-atomic="false"
          >
            {phase === 'greet' && (
              <>
                <FeedbackBubble variant="system">
                  Hi 👋 Want to share feedback about your experience?
                </FeedbackBubble>
                <div className="flex gap-2 mt-2">
                  <Button onClick={() => setPhase('category')}>Yes</Button>
                  <Button variant="outline" onClick={() => setOpen(false)}>
                    Not now
                  </Button>
                </div>
              </>
            )}
            {/* Cumulative scrollback once we've left the greet phase */}
            {phase !== 'greet' && (
              <>
                <FeedbackBubble variant="system">
                  Hi 👋 Want to share feedback about your experience?
                </FeedbackBubble>
                <FeedbackBubble variant="user">Yes</FeedbackBubble>
              </>
            )}

            {/* Category prompt — visible from category phase onward */}
            {phase !== 'greet' && (
              <FeedbackBubble variant="system">
                What would you like to share feedback about?
              </FeedbackBubble>
            )}

            {/* Category options — only on the active category phase */}
            {phase === 'category' && (
              <div className="flex flex-col gap-2 mt-2">
                {CATEGORY_OPTIONS.map((opt) => (
                  <Button
                    key={opt.value}
                    variant="outline"
                    className="justify-start"
                    onClick={() => {
                      setCategory(opt.value);
                      setPhase('rating');
                    }}
                  >
                    {opt.label}
                  </Button>
                ))}
              </div>
            )}

            {/* Category echo — once selected, shows as a user bubble */}
            {category && phase !== 'category' && (
              <FeedbackBubble variant="user">{CATEGORY_LABEL[category]}</FeedbackBubble>
            )}

            {/* Rating prompt — visible from rating phase onward */}
            {(phase === 'rating' || phase === 'text' || phase === 'submitting' || phase === 'done') && (
              <FeedbackBubble variant="system">
                How would you rate your experience?
              </FeedbackBubble>
            )}

            {/* Active 1-5 star picker */}
            {phase === 'rating' && (
              <div className="flex gap-1 mt-2 justify-center">
                {[1, 2, 3, 4, 5].map((n) => (
                  <button
                    key={n}
                    type="button"
                    aria-label={`${n} star${n > 1 ? 's' : ''}`}
                    onClick={() => {
                      setRating(n);
                      setPhase('text');
                    }}
                    className="p-1 hover:scale-110 transition-transform focus:outline-2 focus:outline-offset-1 focus:outline-primary rounded"
                  >
                    <Star
                      className={
                        n <= rating
                          ? 'h-8 w-8 fill-yellow-400 text-yellow-400'
                          : 'h-8 w-8 text-muted-foreground'
                      }
                    />
                  </button>
                ))}
              </div>
            )}

            {/* Rating echo — once selected, shows as a user bubble */}
            {rating > 0 && phase !== 'rating' && (
              <FeedbackBubble variant="user">
                {'★'.repeat(rating)}{'☆'.repeat(5 - rating)}
              </FeedbackBubble>
            )}

            {/* Text phase prompts + cumulative echoes */}
            {(phase === 'text' || phase === 'submitting' || phase === 'done') && (
              <>
                <FeedbackBubble variant="system">
                  What worked well? <span className="opacity-60">(optional)</span>
                </FeedbackBubble>
                {phase === 'done' && positive.trim() && (
                  <FeedbackBubble variant="user">{positive}</FeedbackBubble>
                )}
                {(phase === 'text' || phase === 'submitting') && (
                  <Textarea
                    value={positive}
                    onChange={(e) => setPositive(e.target.value)}
                    maxLength={500}
                    placeholder="Share what helped..."
                    className="mt-2"
                    disabled={phase === 'submitting'}
                  />
                )}

                <FeedbackBubble variant="system">
                  What could we improve? <span className="opacity-60">(optional)</span>
                </FeedbackBubble>
                {phase === 'done' && improvement.trim() && (
                  <FeedbackBubble variant="user">{improvement}</FeedbackBubble>
                )}
                {(phase === 'text' || phase === 'submitting') && (
                  <Textarea
                    value={improvement}
                    onChange={(e) => setImprovement(e.target.value)}
                    maxLength={500}
                    placeholder="Share what could be better..."
                    className="mt-2"
                    disabled={phase === 'submitting'}
                  />
                )}
              </>
            )}

            {/* Done confirmation */}
            {phase === 'done' && (
              <FeedbackBubble variant="system">
                Thanks! Your feedback helps us improve 🙌
              </FeedbackBubble>
            )}
          </div>

          {(phase === 'rating' || phase === 'text' || phase === 'submitting') && (
            <div className="border-t pt-3">
              <Button
                onClick={handleSubmit}
                disabled={rating === 0 || phase === 'submitting'}
                aria-busy={phase === 'submitting'}
                className="w-full"
              >
                {phase === 'submitting' ? 'Sending...' : 'Submit feedback'}
              </Button>
            </div>
          )}

          {phase === 'done' && (
            <div className="border-t pt-3">
              <Button
                onClick={() => {
                  setOpen(false);
                  const until = Date.now() + 60_000;
                  setCooldownUntil(until);
                  setNow(Date.now());
                }}
                className="w-full"
              >
                Close
              </Button>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </>
  );
}
