# Theme System & Design Consistency

## Overview

The coaching platform uses a **light theme** with CSS variables that ensure consistency across all pages. All colors are defined in `src/index.css` and used throughout the UI via Tailwind classes.

---

## CSS Variables

**File:** `src/index.css`

```css
:root {
  --background: 210 20% 98%;      /* Light gray background */
  --foreground: 0 0% 0%;          /* Black text */
  --card: 0 0% 100%;              /* White cards */
  --primary: 220 70% 25%;         /* Dark blue (primary actions) */
  --secondary: 38 92% 55%;        /* Orange (secondary) */
  --muted: 210 5% 40%;            /* Gray (muted text) */
  --border: 210 10% 90%;          /* Light gray borders */
  --input: 210 10% 85%;           /* Input backgrounds */
  --ring: 220 70% 25%;            /* Focus ring color */
  --success: 142 60% 40%;         /* Green (success states) */
  --warning: 38 92% 55%;          /* Orange (warning states) */
  --destructive: 0 84% 60%;       /* Red (dangerous actions) */
}
```

---

## Color Usage Guide

### Primary (--primary: Dark Blue)

**Use for:**
- Primary action buttons (Submit, Save, Confirm)
- Active links and selections
- Icons indicating primary actions
- Progress bars
- Primary focus states

**Examples:**
```tsx
<Button className="bg-primary text-primary-foreground">Submit</Button>
<div className="text-primary">Active state</div>
<div className="border-primary">Primary border</div>
```

### Secondary (--secondary: Orange)

**Use for:**
- Secondary action buttons
- Alternative actions
- Badges and labels
- Less critical information

**Examples:**
```tsx
<Button variant="outline" className="text-secondary">Secondary Action</Button>
```

### Success (--success: Green)

**Use for:**
- Checkmarks and success icons
- Positive confirmations
- Completed states
- Pass/success messages

**Examples:**
```tsx
<CheckCircle2 className="text-success" />
<span className="text-success">✓ Passed</span>
```

### Warning (--warning: Orange)

**Use for:**
- Warning alerts and triangles
- Caution messages
- Pending states
- Tab-switch warnings

**Examples:**
```tsx
<AlertTriangle className="text-warning" />
<span className="text-warning">⚠️ Attention needed</span>
```

### Destructive (--destructive: Red)

**Use for:**
- Delete and cancel buttons
- Error messages
- Blocked/failed states
- Dangerous actions requiring confirmation

**Examples:**
```tsx
<Button variant="destructive">Delete</Button>
<span className="text-destructive">✗ Failed</span>
```

### Muted (--muted: Gray)

**Use for:**
- Secondary text
- Placeholder text
- Disabled text
- Subtle information

**Examples:**
```tsx
<span className="text-muted-foreground">Secondary information</span>
<input placeholder="Type here..." className="placeholder-muted" />
```

### Background & Card

**Use for:**
- Page backgrounds (`bg-background`)
- Card surfaces (`bg-card`)
- Input fields (`bg-input`)

**Examples:**
```tsx
<div className="min-h-screen bg-background">
  <Card className="bg-card">
    <input className="bg-input" />
  </Card>
</div>
```

### Border

**Use for:**
- Dividing lines
- Card borders
- Input borders
- Section separators

**Examples:**
```tsx
<div className="border-b border-border">Divider</div>
<Card className="border-border">...</Card>
<input className="border border-input" />
```

---

## Tailwind Classes for Theming

The platform uses shadcn-ui components that automatically apply theme variables. No need to use hard-coded colors like `bg-blue-50` or `text-amber-600`.

### ✅ Correct (using CSS variables)
```tsx
<div className="bg-background text-foreground">
  <button className="bg-primary text-primary-foreground">Click me</button>
  <span className="text-muted-foreground">Helper text</span>
  <div className="border border-border rounded-lg">Card</div>
</div>
```

### ❌ Incorrect (hard-coded Tailwind colors)
```tsx
<div className="bg-slate-900 text-slate-100">
  <button className="bg-blue-600 text-white">Click me</button>
  <span className="text-slate-400">Helper text</span>
  <div className="border border-slate-700 rounded-lg">Card</div>
</div>
```

---

## Component Examples

### Button Component
```tsx
<Button>Primary Action</Button>
<Button variant="outline">Outline Button</Button>
<Button variant="secondary">Secondary Action</Button>
<Button variant="ghost">Ghost Button</Button>
<Button variant="destructive">Delete</Button>
<Button disabled>Disabled</Button>
```

### Card Component
```tsx
<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
  </CardHeader>
  <CardContent>
    Card content here
  </CardContent>
</Card>
```

### Input Component
```tsx
<input
  className="border border-input rounded-lg px-3 py-2 bg-background text-foreground"
  placeholder="Type here..."
/>
```

### Alert/Status Messages
```tsx
// Success
<div className="bg-success/10 border border-success/20 text-success rounded-lg p-4">
  ✓ Operation completed successfully
</div>

// Warning
<div className="bg-warning/10 border border-warning/20 text-warning rounded-lg p-4">
  ⚠️ Please review before continuing
</div>

// Error
<div className="bg-destructive/10 border border-destructive/20 text-destructive rounded-lg p-4">
  ✗ An error occurred
</div>
```

---

## Assessment & Learning Pages

**Assessment.tsx** (Baseline/Endline):
- Background: `bg-background`
- Cards: `bg-card border-border`
- Info box: `bg-primary/5 border-primary/20` (light blue background)
- Icons: `text-primary`, `text-success`, `text-warning`
- Remaining count: `text-warning`

**TrainingModule.tsx** (Quiz & Content):
- Background: `bg-background` (light, consistent with rest of app)
- Header: `bg-background border-border`
- Cards: `bg-card border-border`
- Loading spinner: `border-b-2 border-primary`
- Tab warnings: `text-warning`
- Completion message: `text-success`

**ScenarioFlow.tsx** (Phase 1):
- Uses same light theme as rest of app
- All components inherit from Assessment.tsx and TrainingModule.tsx patterns
- Consistent color usage across all 5 phases

---

## Dark Mode (Future)

When dark mode is added, only update CSS variables:

```css
@media (prefers-color-scheme: dark) {
  :root {
    --background: 220 20% 10%;      /* Dark background */
    --foreground: 0 0% 100%;        /* White text */
    --card: 220 20% 15%;            /* Dark cards */
    --primary: 220 70% 60%;         /* Lighter blue for visibility */
    --border: 220 10% 20%;          /* Light gray borders */
    /* ... other adjustments ... */
  }
}
```

No changes to component code needed! Tailwind classes will automatically use the new variables.

---

## Migration Notes (from hard-coded colors)

### Assessment.tsx Updates
| Old | New | Why |
|-----|-----|-----|
| `bg-blue-50` | `bg-primary/5` | CSS variable with opacity modifier |
| `border-blue-200` | `border-primary/20` | Consistent with primary system |
| `text-blue-600` | `text-primary` | Direct CSS variable reference |
| `text-amber-600` | `text-warning` | Named color for semantic meaning |
| `bg-amber-50` | `bg-warning/10` | Warning background with opacity |

### TrainingModule.tsx Updates
| Old | New | Why |
|-----|-----|-----|
| `bg-slate-900` | `bg-background` | Consistent light background |
| `bg-slate-800/60` | `bg-card` | Card surfaces |
| `border-slate-700` | `border-border` | Consistent borders |
| `text-teal-400` | `text-primary` | Primary color system |
| `text-slate-200` | `text-foreground` | Foreground text |
| `text-slate-400` | `text-muted-foreground` | Secondary text |

---

## Testing Theme Consistency

To verify all pages use the light theme consistently:

1. **Visual check:**
   - Open Dashboard → light gray background ✓
   - Open Assessment → light background, info box light blue ✓
   - Open TrainingModule quiz → light background with cards ✓
   - Open ScenarioFlow → light background, consistent styling ✓

2. **Color check:**
   - Use browser DevTools color picker
   - Verify background is light (`--background`)
   - Verify borders are light (`--border`)
   - Verify icons use semantic colors (primary, success, warning, destructive)

3. **No hard-coded colors:**
   - Grep for `bg-slate-`, `bg-blue-`, `bg-amber-`, etc.
   - Should only find in node_modules (3rd party libs)
   - All app code should use CSS variables

---

## Adding New Components

When creating new components or pages:

```tsx
// ✅ Always use CSS variables
<div className="min-h-screen bg-background">
  <Card className="bg-card border-border">
    <div className="text-foreground">
      Primary content
    </div>
    <div className="text-muted-foreground">
      Secondary content
    </div>
    <Button className="bg-primary">
      Action
    </Button>
  </Card>
</div>

// ❌ Never hard-code colors
<div className="bg-slate-100">
  <div className="bg-white border border-gray-200">
    <div className="text-black">
      Content
    </div>
  </div>
</div>
```

---

## Resources

- **Tailwind CSS:** https://tailwindcss.com/docs
- **CSS Variables:** https://developer.mozilla.org/en-US/docs/Web/CSS/--*
- **shadcn-ui:** https://ui.shadcn.com (components using theme variables)
- **HSL Color Picker:** https://www.w3schools.com/colors/colors_hsl.asp

---

**Last Updated:** 2026-04-14
