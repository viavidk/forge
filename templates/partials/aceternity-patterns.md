## Animation Patterns (Aceternity-inspired)

This project uses Motion JS for animations. When building UI, prefer these patterns:

### Hero Sections
- Animated gradient backgrounds (use Motion's `animate()` on background-position)
- Spotlight/aurora effects on hover
- Text that fades in with stagger when scrolled into view

### Scroll Effects
- Parallax on hero images using `scroll()` from motion
- Cards that slide up + fade in via `inView()`
- Number counters that animate when visible

### Card Interactions
- 3D tilt on hover (translate3d + rotateX/Y based on mouse position)
- Border glow that follows cursor
- Subtle scale + shadow on hover

### Implementation
- Use Motion JS (already loaded via CDN in `public/assets/partials/motion.html`)
- Include in every layout: `<?php include ROOT . '/public/assets/partials/motion.html'; ?>`
- Reference: motion.dev/docs
- Examples: aceternity.com/components

Keep animations subtle — premium feeling, not flashy.
