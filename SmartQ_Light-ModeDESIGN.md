---
name: Lumina Mobile Admin
colors:
  surface: '#f6fafe'
  surface-dim: '#d6dade'
  surface-bright: '#f6fafe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f4f8'
  surface-container: '#eaeef2'
  surface-container-high: '#e4e9ed'
  surface-container-highest: '#dfe3e7'
  on-surface: '#171c1f'
  on-surface-variant: '#414752'
  inverse-surface: '#2c3134'
  inverse-on-surface: '#edf1f5'
  outline: '#717783'
  outline-variant: '#c0c7d4'
  surface-tint: '#0060aa'
  primary: '#005da6'
  on-primary: '#ffffff'
  primary-container: '#0e76ce'
  on-primary-container: '#fdfcff'
  inverse-primary: '#a3c9ff'
  secondary: '#5d5f5f'
  on-secondary: '#ffffff'
  secondary-container: '#dfe0e0'
  on-secondary-container: '#616363'
  tertiary: '#8b4c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#af6100'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d3e4ff'
  primary-fixed-dim: '#a3c9ff'
  on-primary-fixed: '#001c38'
  on-primary-fixed-variant: '#004882'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#ffdcc1'
  tertiary-fixed-dim: '#ffb779'
  on-tertiary-fixed: '#2e1500'
  on-tertiary-fixed-variant: '#6c3a00'
  background: '#f6fafe'
  on-background: '#171c1f'
  surface-variant: '#dfe3e7'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  stat-number:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  card-padding: 20px
  section-gap: 24px
---

## Brand & Style

The design system is centered on a **Professional Neumorphic** aesthetic, tailored specifically for high-utility mobile dashboards. It evolves the traditional "flat" admin interface into a tactile, physical environment where elements emerge from the background through the interplay of light and shadow.

The target audience consists of administrators and managers who require a calm, focused, and trustworthy tool for overseeing organizational data on the go. The UI evokes a sense of "soft precision"—clean and authoritative, yet approachable and physically satisfying to interact with. By moving away from harsh borders and flat planes, this design system uses depth as a functional tool to establish hierarchy and grouping.

## Colors

The palette is rooted in a monochromatic base of pure white and soft cool grays to facilitate the neumorphic depth effects.

- **Background:** Pure White (#FFFFFF) is used as the base surface.
- **Primary:** A vibrant Professional Blue (#2E86DE) is reserved for active states, primary call-to-actions, and key indicators, providing high-contrast focal points against the soft base.
- **Surface Neutrals:** #F0F4F8 acts as the "recessed" color for input fields or container backgrounds to create contrast against elevated cards.
- **Functional Colors:** Clear red is used sparingly for destructive actions like "Logout" or "Delete," maintaining the professional tone while ensuring safety.

## Typography

This design system utilizes **Manrope** as the primary typeface for its modern, geometric construction that remains highly legible at small scales. **Inter** is used for utility labels to provide a systematic, neutral contrast.

- **Hierarchy:** High-level metrics use `stat-number` to draw immediate attention.
- **Mobile Optimization:** Headline sizes are capped at 24px to ensure they do not wrap aggressively on narrow screens.
- **Readability:** Body text maintains a 500 weight by default to ensure it stands out against the soft shadows of the neumorphic surfaces.

## Layout & Spacing

The layout follows a **fluid mobile-first grid** with a focus on vertical scanning. Elements are organized into logical stacks rather than horizontal rows to accommodate thumb-driven interaction.

- **Margins:** A consistent 16px lateral margin is applied to the main screen container.
- **Gaps:** Use a 12px gap between cards in a list and 24px between distinct functional sections (e.g., Stats vs. List).
- **Safe Areas:** All interactive elements maintain a minimum 44px hit target height, even if their visual footprint is smaller.

## Elevation & Depth

Depth in this design system is created through **Dual-Shadow Neumorphism**. Every elevated element (like a card) must have two shadows:
1. **Top-Left Highlight:** A white (#FFFFFF) shadow with a 5px–10px blur.
2. **Bottom-Right Shadow:** A soft blue-gray shadow (`rgba(163, 177, 198, 0.4)`) with a 5px–10px blur.

**Interactive States:**
- **Default:** Elevated (convex), appearing to push out from the background.
- **Pressed:** Inset (concave), appearing to be pushed into the background. This is achieved by moving the shadows inside the element (inner-shadows).
- **Secondary Surfaces:** Background panels use a subtle `inset` shadow to feel like a carved tray holding elevated cards.

## Shapes

The shape language is consistently "Soft-Rounded." High corner radii are essential to the neumorphic effect as they allow shadows to wrap naturally around the forms.

- **Cards & Buttons:** Use a radius of 1rem (16px) to create a friendly, tactile feel.
- **Input Fields:** Use a radius of 0.75rem (12px).
- **Stats Containers:** Large rounded corners (1.5rem) help distinguish them as top-level dashboard metrics.

## Components

### Cards (Mobile Table Alternative)
The desktop table is replaced by a **Vertical Card List**. Each organization is a card:
- **Header:** Organization Name (Bold) + Action Menu (Icon).
- **Body:** 2-column grid for metadata (Location, Contact) and a horizontal row for counts (Admins, Services, Staff) using small pill-shaped chips.
- **Footer:** Two equal-width buttons for "Edit" and "Delete" nested within the card padding.

### Stats Metrics
Stats are displayed in a 2x2 grid. Each card features a large `stat-number` centered above a `label-caps` descriptor. Use the Neumorphic elevation to make these feel like physical buttons.

### Primary Buttons
Primary actions (e.g., "Add Organization") use the Primary Blue as the background. To maintain the neumorphic style, the blue button should have a slightly darker blue shadow and a lighter blue highlight, rather than white/gray.

### Tabs & Segmented Controls
The "Organization/Admins" toggle should look like a recessed "tray" with the active item appearing as a raised button moving within that tray.

### Inputs
Search bars and text fields should be `inset` (concave), creating a physical "well" for the user to type into.