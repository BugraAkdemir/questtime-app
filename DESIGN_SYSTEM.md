# StudyQuest Design System

## Design Philosophy

**Core Feeling:** Calm focus + subtle game energy
**Target:** Premium, modern, not childish, not aggressive
**Approach:** Minimal UI, no clutter, one main action per screen

---

## Color Palette

### Primary Colors
- **Primary Purple/Violet:** `#7C3AED` (Violet-600 - more vibrant)
  - Light: `#8B5CF6` (Violet-500)
  - Dark: `#6D28D9` (Violet-700)
  - Usage: Primary actions, selected states, focus elements, app branding

### Secondary Colors
- **Soft Blue:** `#3B82F6` (Blue-500 - more vibrant)
  - Light: `#60A5FA` (Blue-400)
  - Dark: `#2563EB` (Blue-600)
  - Usage: Secondary accents, informational elements, gradients

### XP / Reward Colors
- **Neon Green:** `#10B981` (Emerald-500)
- **Cyan:** `#06B6D4` (Cyan-500)
- **Neon:** `#34D399` (Emerald-400)
- **Gold:** `#F59E0B` (Amber-500) - New for achievements
- Usage: XP displays, rewards, achievements, positive feedback, leaderboard medals

### Background Colors
- **Background:** `#0A0E27` (Deep navy - near-black)
- **Surface:** `#111827` (Dark gray)
- **Surface Elevated:** `#1F2937` (Lighter dark gray)
- **Surface Variant:** `#374151` (Medium gray)

### Text Colors
- **Primary Text:** `#F3F4F6` (Gray-100 - soft, not pure white)
- **Secondary Text:** `#9CA3AF` (Gray-400)
- **Tertiary Text:** `#6B7280` (Gray-500)

**Important:** Avoid pure white (`#FFFFFF`) for text. Use soft gray tones for better readability and premium feel.

---

## Typography

### Font Family
- Clean sans-serif (Inter / SF Pro style)
- System default with fallback

### Text Styles

#### Display (Large Numbers)
- **Display Large:** 48px, Bold, -1.0 letter spacing
  - Usage: Timer, large XP numbers, level numbers
- **Display Medium:** 36px, Bold, -0.5 letter spacing
  - Usage: Section headers, important numbers
- **Display Small:** 28px, Bold, -0.5 letter spacing
  - Usage: Sub-headers, medium emphasis

#### Headline (Titles)
- **Headline Medium:** 20px, Semi-bold (600), -0.5 letter spacing
  - Usage: Section titles, card titles
- **Headline Small:** 18px, Semi-bold (600), -0.3 letter spacing
  - Usage: Sub-section titles

#### Body (Content)
- **Body Large:** 16px, Medium (500), normal letter spacing
  - Usage: Primary content text
- **Body Medium:** 14px, Medium (500), normal letter spacing
  - Usage: Secondary content, descriptions
- **Body Small:** 12px, Medium (500), 0.2 letter spacing
  - Usage: Labels, metadata, timestamps

#### Label (Interactive)
- **Label Large:** 14px, Semi-bold (600), 0.5 letter spacing
  - Usage: Buttons, chips, interactive elements

### Weight Guidelines
- **Medium (500):** Primary text, body content
- **Semi-bold (600):** Headlines, labels, emphasis
- **Bold (700):** XP numbers, levels, timer, strong emphasis

---

## Spacing System

Consistent 4px base unit:

- **XS:** 4px - Tight spacing, icon padding
- **SM:** 8px - Small gaps, compact layouts
- **MD:** 16px - Standard padding, card padding
- **LG:** 24px - Section spacing, large gaps
- **XL:** 32px - Major section breaks
- **XXL:** 48px - Screen-level spacing

### Usage Examples
- Card padding: `spacingMD` (16px)
- Section gaps: `spacingLG` (24px)
- Screen margins: `spacingMD` (16px)
- Button padding: `spacingXL` horizontal, `spacingMD` vertical

---

## Border Radius

- **SM:** 8px - Small elements, badges
- **MD:** 12px - Buttons, cards, standard elements
- **LG:** 16px - Large cards, dialogs
- **XL:** 24px - Extra large containers
- **Full:** 999px - Pills, circular elements

---

## Animation Guidelines

### Duration
- **Fast:** 200ms - Quick feedback, hover states
- **Normal:** 300ms - Standard transitions
- **Slow:** 400ms - Complex animations, page transitions

### Curves
- **Default:** `Curves.easeInOut` - Smooth, natural motion
- Avoid: Linear, bounce, elastic (too playful)

### Principles
- **Breathing/Pulsing:** Subtle scale animations for focus elements
- **Fade:** Opacity transitions for content changes
- **Slide:** Gentle position changes
- **Avoid:** Fast, aggressive, or flashy effects

---

## Component Styles

### Buttons

#### Primary Button (Elevated)
- Background: Primary purple gradient (purple → light purple → blue)
- Text: White, Semi-bold (600)
- Padding: 32px horizontal, 16px vertical
- Border radius: 12px (MD)
- Elevation: 2 (with shadow)
- Shadow: Primary purple with 30% opacity
- Hover state: Lighter purple
- Pressed state: Darker purple
- Animation: 300ms ease-in-out

#### Text Button
- Text: Secondary text color
- No background
- Padding: 16px horizontal, 8px vertical

### Cards

#### Standard Card
- Background: Surface color
- Border radius: 16px (LG)
- Elevation: 0 (flat design)
- Padding: 16px (MD)
- Margin: 0 (use parent spacing)

#### Quest Card
- Same as standard card
- Subtle hover effect (scale 1.02)
- Selected state: Soft glow (primary purple)

### Timer

#### Circular Timer
- Size: 280px diameter
- Background: Surface color
- Progress: Primary purple to cyan gradient
- Shadow: Soft glow (primary purple, 20% opacity)
- Time display: Display Large style
- Status text: Body Medium, secondary color

### Progress Indicators

#### Linear Progress
- Height: 8px
- Background: Surface elevated
- Value color: Primary purple
- Border radius: 4px (half of height)

#### Circular Progress
- Stroke width: 8px
- Same color scheme as linear

### XP Display

#### XP Badge
- Background: XP gradient (green → cyan → neon, 3-color gradient)
- Border radius: 12px (MD)
- Shadow: Soft glow (enhanced, dual-layer)
- Text: White, Bold
- Padding: 12px horizontal, 8px vertical

#### Leaderboard Podium
- Top 3: Special medal colors (Gold, Silver, Bronze)
- Podium base: Gradient with medal color
- Shadow: Premium glow effect
- Height: Variable (1st place tallest)

---

## Layout Structure

### Home / Timer Screen

**Layout:**
1. Top: Level and XP card (compact)
2. Center: Circular timer (centered, prominent)
3. Bottom: Start Quest button (when idle) or timer controls
4. Recent quests list (below fold)

**Principles:**
- Centered circular timer is the hero element
- Single primary action: "Start Quest"
- Minimal status info visible
- XP gain preview in level card

### Quest Selection

**Layout:**
- Card-based subject list
- Subject icon + name
- Subtle glow on selected quest
- Duration and difficulty chips
- Custom duration input (when enabled)

**Principles:**
- One quest per card
- Clear visual hierarchy
- Easy selection with visual feedback

### XP / Level Feedback

**Layout:**
- Full-screen modal on quest completion
- Large XP number with gradient
- Confetti animation (subtle, 3 seconds)
- Total XP and level update
- Single "Awesome!" button

**Principles:**
- Clear, satisfying animation
- Short duration (don't interrupt flow)
- Positive reinforcement

### Stats Screen

**Layout:**
- Level display (large, centered)
- Progress bar
- Stats grid (2 columns)
- Quest history list
- Language toggle button

**Principles:**
- Focus on trends, not number overload
- Streak and total time visible
- Simple charts or bars
- Clean, scannable layout

### Leaderboard Screen

**Layout:**
- Current user rank card (if logged in)
- Top 3 podium (Gold, Silver, Bronze medals)
- Complete leaderboard list
- Pull-to-refresh support

**Principles:**
- Top 3 prominently displayed with special design
- User's own rank highlighted
- Clear visual hierarchy
- Real-time updates

---

## Design Decisions

### Why Dark Theme?
- Reduces eye strain during long study sessions
- Creates focused, immersive environment
- Modern, premium aesthetic
- Better for low-light conditions

### Why Soft Gray Text?
- Pure white is too harsh on dark backgrounds
- Soft gray provides better contrast and readability
- More premium, refined appearance
- Reduces visual fatigue

### Why Minimal UI?
- Reduces cognitive load
- Focuses attention on the task (studying)
- Faster to understand and use
- Cleaner, more professional appearance

### Why Purple/Violet Primary?
- More vibrant than indigo (#7C3AED vs #6366F1)
- Associated with focus and concentration
- Not aggressive or childish
- Modern, tech-forward feeling
- Good contrast on dark backgrounds
- Creates premium, energetic feel

### Why Green/Cyan for XP?
- Positive, rewarding feeling
- Stands out without being aggressive
- Clear association with growth and progress
- Distinct from primary actions

### Why Soft Animations?
- Smooth, natural motion feels premium
- Doesn't distract from studying
- Provides feedback without being jarring
- Professional, polished experience

---

## Do NOT

❌ Add unnecessary decorations
❌ Use bright red or harsh colors
❌ Overuse shadows or gradients
❌ Fast or aggressive animations
❌ Pure white text
❌ Cluttered layouts
❌ Too many colors
❌ Flashy effects

---

## Implementation Notes

All design tokens are available in `lib/theme/app_theme.dart`:

- Colors: `AppTheme.primaryPurple`, `AppTheme.xpGreen`, etc.
- Spacing: `AppTheme.spacingMD`, `AppTheme.spacingLG`, etc.
- Radius: `AppTheme.radiusMD`, `AppTheme.radiusLG`, etc.
- Animations: `AppTheme.animationNormal`, `AppTheme.animationCurve`
- Gradients: `AppTheme.xpGradient`, `AppTheme.primaryGradient`, `AppTheme.goldGradient`
- Shadows: `AppTheme.softGlow`, `AppTheme.premiumGlow`, `AppTheme.cardShadow`, `AppTheme.elevatedShadow`

Use these tokens consistently throughout the app for maintainability and consistency.

