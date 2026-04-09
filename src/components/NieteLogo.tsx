interface NieteLogoProps {
  size?: "sm" | "md" | "lg";
  showText?: boolean;
}

const sizes = {
  sm: { img: "w-8 h-8", text: "text-lg" },
  md: { img: "w-12 h-12", text: "text-2xl" },
  lg: { img: "w-14 h-14", text: "text-3xl" },
};

export function NieteLogo({ size = "md", showText = true }: NieteLogoProps) {
  const s = sizes[size];
  return (
    <div className="flex items-center gap-2">
      <img src="/niete-logo.svg" alt="Niete" className={`${s.img} object-contain`} />
      {showText && (
        <span className={`font-display font-bold text-foreground ${s.text}`}>Niete</span>
      )}
    </div>
  );
}
