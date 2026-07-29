---
name: Aetheric Depth
colors:
  surface: '#1a063a'
  surface-dim: '#1a063a'
  surface-bright: '#413062'
  surface-container-lowest: '#150135'
  surface-container-low: '#231043'
  surface-container: '#271547'
  surface-container-high: '#322052'
  surface-container-highest: '#3d2b5e'
  on-surface: '#ebdcff'
  on-surface-variant: '#cbc4ce'
  inverse-surface: '#ebdcff'
  inverse-on-surface: '#382759'
  outline: '#958f98'
  outline-variant: '#4a454d'
  surface-tint: '#d3beeb'
  primary: '#d3beeb'
  on-primary: '#38294d'
  primary-container: '#1a0b2e'
  on-primary-container: '#88769f'
  inverse-primary: '#68577e'
  secondary: '#e9b3ff'
  on-secondary: '#510074'
  secondary-container: '#7d01b1'
  on-secondary-container: '#e5a9ff'
  tertiary: '#d3bbff'
  on-tertiary: '#3f0689'
  tertiary-container: '#1b0044'
  on-tertiary-container: '#9067dc'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#eddcff'
  primary-fixed-dim: '#d3beeb'
  on-primary-fixed: '#231437'
  on-primary-fixed-variant: '#4f4065'
  secondary-fixed: '#f6d9ff'
  secondary-fixed-dim: '#e9b3ff'
  on-secondary-fixed: '#310048'
  on-secondary-fixed-variant: '#7200a3'
  tertiary-fixed: '#ebdcff'
  tertiary-fixed-dim: '#d3bbff'
  on-tertiary-fixed: '#260059'
  on-tertiary-fixed-variant: '#572ba0'
  background: '#1a063a'
  on-background: '#ebdcff'
  surface-variant: '#3d2b5e'
typography:
  display-lg:
    fontFamily: Sora
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter: 16px
  element-gap: 12px
---

## Brand & Style
This design system centers on a "Deep Purple Neumorphic" aesthetic, moving away from standard flat surfaces toward a tactile, extruded interface. The brand personality is mysterious, premium, and immersive, targeting high-end tech enthusiasts, creative studios, or futuristic fintech platforms.

The style is a refined evolution of Neumorphism. It utilizes soft, physical metaphors where elements appear to be molded from the background material itself. By using a monochromatic purple foundation with high-energy accents, the UI evokes a sense of "digital velvet"—deep, soft, yet technologically advanced. The emotional response is one of calm focus punctuated by moments of electric excitement.

## Colors
The palette is built upon a very deep, rich purple base (`#1a0b2e`). Neumorphic depth is achieved through a specific relationship between three tones: the base surface, a deeper violet shadow for "recessed" or "extruded" edges, and a muted lavender highlight to simulate light hitting the top edge of a physical shape.

- **Primary Surface:** `#1a0b2e` (The canvas).
- **Shadow (Dark):** `#0d0517` (Used for the bottom-right shadows).
- **Highlight (Light):** `#2a1645` (Used for the top-left light source).
- **Accent:** Electric Violet (`#bf5af2`) is reserved for critical interactions, active states, and high-priority call-to-actions to provide a "neon" glow against the dark depth.

## Typography
The typography strategy balances geometric modernism with technical precision. **Sora** is used for headlines to provide a bold, futuristic look that complements the rounded shapes of the UI. **Hanken Grotesk** serves as the primary body face, offering exceptional legibility and a clean, sharp appearance against dark backgrounds. **JetBrains Mono** is employed for small labels and metadata to lean into the "tech" nature of the design system.

Headlines should use tight letter-spacing to feel impactful. Body text requires slightly increased line height (1.5x+) to ensure readability against the low-contrast neumorphic shadows of the container surfaces.

## Layout & Spacing
This design system utilizes a **fluid grid** with an 8px base unit. Because neumorphic elements require significant "breathing room" for their soft shadows to be visible without overlapping, margins and gutters are more generous than in traditional flat designs.

- **Desktop:** 12-column grid with 24px gutters and 64px side margins.
- **Tablet:** 8-column grid with 16px gutters and 32px side margins.
- **Mobile:** 4-column grid with 16px gutters and 16px side margins.

Avoid "crowding" elements. Each card or button needs a minimum clearance equal to its shadow blur radius (typically 12px to 20px) to maintain the illusion of depth.

## Elevation & Depth
Elevation is not conveyed through Z-axis stacking but through surface deformation. We use two primary states:

1.  **Extruded (Raised):** Created with a dual shadow: a dark shadow (`#0d0517`) at `4px 4px 12px` and a light highlight (`#2a1645`) at `-4px -4px 12px`. This makes the element appear to pop out of the background.
2.  **Inset (Sunken):** Created using `inset` shadows with the same color logic. This is primarily used for input fields and pressed button states.

To maintain the "Deep Purple" theme, shadows should never be pure black or grey; they must always contain a violet tint to preserve color saturation in the dark regions.

## Shapes
Neumorphism relies on rounded corners to allow light and shadow to wrap naturally around the edges. This design system uses a "Rounded" (Level 2) logic. 

- **Small elements (Buttons/Inputs):** 0.5rem (8px).
- **Medium elements (Cards/Modals):** 1rem (16px).
- **Large containers:** 1.5rem (24px).

Avoid sharp 0px corners, as they break the soft "molded" physical metaphor.

## Components
- **Buttons:** Primary buttons should be "Extruded" in their default state. On hover, the shadow intensity increases. On active (click), they transition to an "Inset" state. The text should use the Electric Violet accent or a high-contrast white.
- **Cards:** Cards use the standard Extruded shadow. They should not have borders; the depth transition itself defines the edge.
- **Input Fields:** Fields should always be "Inset" to look like hollows carved into the surface. The cursor and focus ring should use the Electric Violet accent.
- **Chips/Tags:** Use a smaller, subtler version of the Extruded state. When selected, the chip can glow with an inner shadow of Electric Violet.
- **Lists:** Items are separated by subtle "incised" lines (a 1px line of the dark shadow color paired with a 1px line of the highlight color below it).
- **Progress Bars:** The track is "Inset," and the filler is a glowing gradient of Electric Violet to Tertiary Purple, appearing as if "liquid light" is filling a groove.