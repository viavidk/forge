# UX laws — evidence-based interface rules

These are empirically validated principles. Apply them during design,
cite them in review findings, and treat them as hard constraints rather
than style preferences.

## Hick's Law — fewer choices, faster decisions

**Rule:** Decision time grows with the number of visible options.

**Apply when:** Designing navigation menus, action buttons on a page,
form fields, filter controls, or any screen where the user chooses.

**Concrete limits:**
- Primary navigation: max 7 items at any one level
- Action buttons visible simultaneously: max 3 (one primary, two secondary)
- Form steps with >10 fields: split into progressive disclosure or wizard steps
- Dropdown with >15 options: add search/filter input

**Violation examples:**
- Footer with 40 links grouped flat — MAJOR
- Dashboard showing 12 "quick action" buttons — MAJOR
- Settings page with 30 toggles on one screen — MAJOR

## Fitts's Law — size + distance = usability

**Rule:** Time to click a target depends on its size and distance from
the cursor/finger. Bigger and closer = faster and less error-prone.

**Apply when:** Designing buttons, links, form inputs, or any
interactive element — especially on mobile.

**Concrete limits:**
- Touch targets: minimum 44×44 px (Apple HIG + WCAG 2.5.5)
- Mouse targets: minimum 32×32 px, 24 px spacing between clickable items
- Primary CTA button: minimum 48 px tall on mobile
- Destructive actions (delete, logout): MUST be separated from primary
  actions by ≥ 40 px to prevent misclicks

**Violation examples:**
- "Delete" button right next to "Save" — CRITICAL
- 28×28 px icon buttons on mobile — MAJOR
- Link-only navigation with 12 px line-height — MAJOR

## Law of Proximity — closeness implies relationship

**Rule:** Users perceive elements that are close together as related.
Elements far apart are perceived as unrelated.

**Apply when:** Grouping form fields, arranging card content, structuring
filter sections, placing labels near inputs.

**Concrete limits:**
- Label-to-input gap: 4–8 px
- Gap between unrelated sections: ≥ 32 px (Tailwind `space-y-8` or `gap-8`)
- Related fields grouped with visible separator or shared background
- Never let a label sit equidistant between two inputs

**Violation examples:**
- Label 16 px above input, 18 px below previous input — MAJOR (ambiguous)
- Billing + shipping address fields interleaved without separator — MAJOR
- Action buttons floating alone with no visible relationship to content — MAJOR

## Miller's Law — ~7 items in working memory

**Rule:** People can hold roughly 5–9 items in short-term memory.
Cognitive load increases sharply beyond that.

**Apply when:** Designing numbered lists, comparison tables, dashboard
KPI strips, step indicators, cards in a row.

**Concrete limits:**
- Comparison table columns: max 5
- Dashboard KPI cards in one row: max 5
- Navigation breadcrumb depth: max 5 levels (go flatter if possible)
- Multi-step form: max 7 total steps — if more, group into phases
- Bulleted feature lists: max 7 per group — split with subheadings beyond that

**Violation examples:**
- Pricing table with 8 plans side by side — MAJOR
- Dashboard header with 9 metric cards — MAJOR
- Onboarding with 12 sequential steps — MAJOR

## Jakob's Law — match familiar patterns

**Rule:** Users spend most of their time on OTHER sites. They expect
your site to work like those. Novel patterns increase cognitive load
even if they are technically "better".

**Apply when:** Deciding whether to invent a new interaction pattern vs.
follow an established one.

**Concrete rules:**
- Login form: email/username + password + "Log in" button, in that order
- E-commerce cart: top-right corner with item count badge
- Search: top of page with magnifying glass icon
- Settings: gear icon, typically top-right in header or sidebar
- Destructive actions: red/orange color, secondary placement
- Primary action in forms: bottom-right or full-width at bottom

**Violation examples (all MAJOR unless justified by A/B data):**
- Login form with password above email — MAJOR
- Cart icon in bottom-left corner — MAJOR
- "Save" button in top-left of a form — MAJOR
- Red color used for primary positive action — MAJOR
- Hamburger menu opening rightward from desktop nav — MAJOR

## Enforcement

All five laws are checked by `frontend-reviewer`. A CRITICAL finding
under Fitts's Law (destructive action adjacent to primary) blocks
further progress. MAJOR findings from other laws count toward the
Frontend score — three or more MAJOR = score drops below 8 → loop again.
