import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { ChevronLeft, ChevronRight } from "lucide-react";

export interface Slide {
  title: string;
  body: string;
  image_url?: string;
}

interface RevealSlidesProps {
  slides: Slide[];
  onDone: () => void;
}

export default function RevealSlides({ slides, onDone }: RevealSlidesProps) {
  const [currentIndex, setCurrentIndex] = useState(0);

  // If no slides, immediately advance
  useEffect(() => {
    if (slides.length === 0) {
      onDone();
    }
  }, [slides.length, onDone]);

  if (slides.length === 0) {
    return null;
  }

  const currentSlide = slides[currentIndex];
  const isLast = currentIndex === slides.length - 1;
  const progress = ((currentIndex + 1) / slides.length) * 100;

  const handlePrevious = () => {
    setCurrentIndex((prev) => Math.max(0, prev - 1));
  };

  const handleNext = () => {
    setCurrentIndex((prev) => Math.min(slides.length - 1, prev + 1));
  };

  const handleDone = () => {
    onDone();
  };

  return (
    <Card className="border-blue-500/30 bg-blue-500/5">
      <CardHeader>
        <CardTitle className="text-lg">{currentSlide.title}</CardTitle>
        <Progress value={progress} className="mt-2" />
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Slide Content */}
        <div className="min-h-48 space-y-3">
          {currentSlide.image_url && (
            <img
              src={currentSlide.image_url}
              alt={currentSlide.title}
              className="max-h-48 w-full object-cover rounded-md"
            />
          )}
          <p className="text-sm leading-relaxed text-foreground whitespace-pre-wrap">
            {currentSlide.body}
          </p>
        </div>

        {/* Navigation Controls */}
        <div className="flex items-center justify-between gap-2 border-t border-secondary/20 pt-4">
          <Button
            variant="outline"
            size="sm"
            onClick={handlePrevious}
            disabled={currentIndex === 0}
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            Previous
          </Button>

          <span className="text-xs text-muted-foreground">
            {currentIndex + 1} of {slides.length}
          </span>

          {isLast ? (
            <Button variant="default" size="sm" onClick={handleDone}>
              Continue
            </Button>
          ) : (
            <Button
              variant="outline"
              size="sm"
              onClick={handleNext}
              disabled={currentIndex === slides.length - 1}
            >
              Next
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
