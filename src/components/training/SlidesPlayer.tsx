import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent } from "@/components/ui/card";
import { ChevronLeft, ChevronRight, CheckCircle2 } from "lucide-react";

export interface Slide {
  title: string;
  content: string;
  keyPoint?: string;
  table?: { headers: string[]; rows: string[][] };
  bullets?: string[];
  type?: "title" | "content" | "table" | "activity" | "comparison";
}

interface SlidesPlayerProps {
  slides: Slide[];
  onCompleted: () => void;
  completed: boolean;
}

const SLIDE_LOCK_DURATION = 15; // seconds

export default function SlidesPlayer({ slides, onCompleted, completed }: SlidesPlayerProps) {
  const [current, setCurrent] = useState(0);
  const [countdown, setCountdown] = useState(SLIDE_LOCK_DURATION);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const slide = slides[current];
  const progress = ((current + 1) / slides.length) * 100;
  const isLast = current === slides.length - 1;
  const isNextDisabled = countdown > 0;

  useEffect(() => {
    setCountdown(SLIDE_LOCK_DURATION);
    if (intervalRef.current) clearInterval(intervalRef.current);

    intervalRef.current = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          if (intervalRef.current) clearInterval(intervalRef.current);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [current]);

  const next = () => {
    if (isNextDisabled) return;
    if (isLast) {
      onCompleted();
    } else {
      setCurrent((i) => i + 1);
    }
  };

  const prev = () => setCurrent((i) => Math.max(0, i - 1));

  return (
    <div className="space-y-4">
      {/* Progress */}
      <div className="flex items-center justify-between text-sm text-muted-foreground mb-1">
        <span>Slide {current + 1} of {slides.length}</span>
        {completed && (
          <span className="flex items-center gap-1 text-green-500 font-medium">
            <CheckCircle2 className="w-4 h-4" /> Completed
          </span>
        )}
      </div>
      <Progress value={progress} className="h-1.5" />

      {/* Slide card */}
      <Card className="min-h-[280px] sm:min-h-[380px] border-primary/20 bg-card">
        <CardContent className="p-4 sm:p-8 flex flex-col justify-between min-h-[280px] sm:min-h-[380px]">
          <div className="flex-1">
            {/* Title */}
            <h2 className="text-xl font-display font-bold text-foreground mb-4 leading-tight">
              {slide.title}
            </h2>

            {/* Main content */}
            {slide.content && (
              <p className="text-muted-foreground leading-relaxed mb-4">{slide.content}</p>
            )}

            {/* Bullet list */}
            {slide.bullets && slide.bullets.length > 0 && (
              <ul className="space-y-2 mb-4">
                {slide.bullets.map((b, i) => (
                  <li key={i} className="flex items-start gap-2 text-foreground">
                    <span className="mt-1.5 w-2 h-2 rounded-full bg-primary shrink-0" />
                    <span>{b}</span>
                  </li>
                ))}
              </ul>
            )}

            {/* Table */}
            {slide.table && (
              <div className="overflow-x-auto mt-2 mb-4">
                <table className="w-full text-sm border-collapse">
                  <thead>
                    <tr>
                      {slide.table.headers.map((h, i) => (
                        <th key={i} className="bg-primary/10 text-foreground font-semibold px-3 py-2 text-left border border-border">
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {slide.table.rows.map((row, ri) => (
                      <tr key={ri} className={ri % 2 === 0 ? "bg-background" : "bg-accent/30"}>
                        {row.map((cell, ci) => (
                          <td key={ci} className="px-3 py-2 border border-border text-muted-foreground">
                            {cell}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {/* Key point highlight */}
            {slide.keyPoint && (
              <div className="mt-4 p-3 rounded-lg bg-primary/10 border-l-4 border-primary">
                <p className="text-sm font-semibold text-primary">{slide.keyPoint}</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Navigation */}
      <div className="flex justify-between gap-3">
        <Button variant="outline" onClick={prev} disabled={current === 0}>
          <ChevronLeft className="w-4 h-4 mr-1" /> Previous
        </Button>
        <Button
          onClick={next}
          disabled={isNextDisabled}
          className="bg-primary hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isNextDisabled
            ? `Read slide first (${countdown}s)`
            : isLast
              ? (completed ? "Completed ✓" : "Finish Slides")
              : <>Next <ChevronRight className="w-4 h-4 ml-1" /></>
          }
        </Button>
      </div>

      {/* Slide dots */}
      <div className="flex justify-center gap-1.5 flex-wrap">
        {slides.map((_, i) => (
          <button
            key={i}
            onClick={() => setCurrent(i)}
            className={`w-2 h-2 rounded-full transition-all ${
              i === current ? "bg-primary w-4" : i < current ? "bg-primary/50" : "bg-muted"
            }`}
          />
        ))}
      </div>
    </div>
  );
}
