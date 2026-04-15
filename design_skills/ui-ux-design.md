# BowlersNetwork — Mobile UI/UX Design Guide (Flutter)

Apply this guide before writing any widget. It captures the visual language, interaction patterns, and design philosophy of the BowlersNetwork mobile app.

The design system is shared with the web frontend — same colors, same typography scale, same component patterns. The mobile app must feel like the same product, not a different one.

For platform context, load `system-knowledge`. For Flutter architecture and stack, load `app-knowledge`.

---

## Design Philosophy

### 1. Surface Hierarchy Creates Depth

Screens are built from layered surfaces, not flat sections. Every visual element sits on a surface, and surfaces are distinguished by background color and border treatment.

- **Page background** (`bgPrimary`) is the lowest layer
- **Cards** (`bgSurface`) float above with `borderDefault` borders
- **Elevated elements** (modals, bottom sheets, dropdowns) use `bgSurfaceElevated`
- **Interactive press state** uses `InkWell` ripple with subtle accent overlay

Never place content directly on the screen background without a surface. Even simple text sections get a card wrapper.

### 2. Accent Color Guides the Eye

The accent color (`#8bc342`) is used surgically — not everywhere, but precisely where the user's attention should go:

- **Primary CTAs:** solid accent background with shadow glow
- **Active/selected states:** accent-subtle background, accent-colored text
- **Progress indicators:** accent-tinted gradients
- **Icons in section headers:** sit in accent-tinted square containers
- **Decorative elements:** corner orbs and blur blobs use low-opacity accent

If everything is accent-colored, nothing stands out. Reserve accent for actions and indicators.

### 3. Gradients and Blur Create Atmosphere

Hero sections and featured cards use a signature visual treatment:

- Background gradient: accent at 10% opacity → accent at 5% → transparent (use `LinearGradient`)
- Decorative blur blobs: positioned circles with `BackdropFilter(filter: ImageFilter.blur(...))` or simply low-opacity colored circles
- Corner orbs on cards: `Positioned(top: -50, right: -50, child: Container(...))` with `accent` at 5% opacity, fading to 10% on tap

These are not applied to every card — only heroes, featured sections, and special states (invitations, completion banners).

### 4. Typography Encodes Hierarchy

Size, weight, and color work together. Never rely on size alone.

| Role | Size (sp) | Weight | Color | Letter Spacing |
|---|---|---|---|---|
| Page title (hero) | 26 | w700 | textPrimary | -0.4 |
| Section title | 16 | w600 | textPrimary | 0 |
| Card title | 15 | w600 | textPrimary | 0 |
| Body | 14 | w400 | textPrimary | 0 |
| Body small | 13 | w400 | textPrimary | 0 |
| Secondary text | 12 | w400 | textSecondary | 0 |
| Caption / label | 11 | w600 | textTertiary | 0.4 |
| Micro | 10 | w500 | textTertiary | 0 |

Section labels use **uppercase** with letter spacing 0.4: `font-size: 11, weight: w600, color: textTertiary, letter-spacing: 0.4`.

All numeric displays use `fontFeatures: [FontFeature.tabularFigures()]` to keep numbers aligned during animation/updates.

### 5. Transitions Are Fast and Purposeful

- Micro interactions (press feedback, focus): 150ms
- Screen transitions: 250ms (use `CupertinoPageTransitionsBuilder` on iOS, `OpenUpwardsPageTransitionsBuilder` on Android)
- Modal entry: 200ms with `Curves.easeOutCubic`
- Progress bars: 1000ms with `Curves.easeOut`

Only animate `transform` and `opacity`. Never animate width, height, padding, margin — they trigger layout passes and cause jank.

---

## Theme Setup

### Color tokens (define in `core/theme/app_colors.dart`)

```dart
class AppColors {
  // Dark theme (default)
  static const bgPrimary = Color(0xFF0A0A0A);
  static const bgSurface = Color(0xFF111111);
  static const bgSurfaceElevated = Color(0xFF1A1A1A);
  static const bgSurfaceHover = Color(0xFF222222);
  static const borderDefault = Color(0xFF1F1F1F);
  static const borderStrong = Color(0xFF2E2E2E);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9A9A9A);
  static const textTertiary = Color(0xFF5A5A5A);
  static const accent = Color(0xFF8BC342);
  static const accentHover = Color(0xFF7DB33A);
  static const accentSubtle = Color(0x1A8BC342); // 10% opacity
  static const accentGlow = Color(0x268BC342); // 15% opacity
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
}

class AppColorsLight {
  static const bgPrimary = Color(0xFFFAFAFA);
  static const bgSurface = Color(0xFFFFFFFF);
  static const bgSurfaceElevated = Color(0xFFFFFFFF);
  static const bgSurfaceHover = Color(0xFFF0F0F0);
  static const borderDefault = Color(0xFFE8E8E8);
  static const borderStrong = Color(0xFFD4D4D4);
  static const textPrimary = Color(0xFF0F0F0F);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textTertiary = Color(0xFFA0A0A0);
  static const accent = Color(0xFF6DA030);
  static const accentHover = Color(0xFF5E8C28);
  static const accentSubtle = Color(0x146DA030);
}
```

Wire these into a custom `ThemeExtension<AppThemeColors>` so any widget can do `Theme.of(context).extension<AppThemeColors>()!.accent`.

**Theme persistence:** Store `bn_theme` in `shared_preferences` with values `light | dark | system`. Default to `system`. Toggle in Settings.

### Typography (define in `core/theme/app_text_styles.dart`)

```dart
class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: 'Geist',
    fontFamilyFallback: ['SF Pro Text', 'Roboto', 'system-ui'],
  );

  static TextStyle pageTitle(BuildContext c) => _base.copyWith(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: c.colors.textPrimary, letterSpacing: -0.4,
  );

  static TextStyle sectionTitle(BuildContext c) => _base.copyWith(
    fontSize: 16, fontWeight: FontWeight.w600, color: c.colors.textPrimary,
  );

  static TextStyle cardTitle(BuildContext c) => _base.copyWith(
    fontSize: 15, fontWeight: FontWeight.w600, color: c.colors.textPrimary,
  );

  static TextStyle body(BuildContext c) => _base.copyWith(
    fontSize: 14, color: c.colors.textPrimary,
  );

  static TextStyle bodySmall(BuildContext c) => _base.copyWith(
    fontSize: 13, color: c.colors.textPrimary,
  );

  static TextStyle secondary(BuildContext c) => _base.copyWith(
    fontSize: 12, color: c.colors.textSecondary,
  );

  static TextStyle label(BuildContext c) => _base.copyWith(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: c.colors.textTertiary, letterSpacing: 0.4,
  );

  static TextStyle number(BuildContext c) => body(c).copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
```

**Font registration:** Add Geist variable font to `pubspec.yaml`. Fall back to system fonts if Geist fails to load.

### Spacing scale (define in `core/theme/app_spacing.dart`)

Base unit: **4dp**. Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xl2 = 32.0;
  static const xl3 = 40.0;
  static const xl4 = 48.0;
  static const xl5 = 64.0;
}
```

**Screen padding:** 16dp on all sides for content. Hero sections get 24dp.

### Border radius scale

| Token | Radius | Usage |
|---|---|---|
| `radiusSm` | 8 | Badges, small buttons, icon containers |
| `radiusMd` | 12 | Buttons, inputs, icon containers |
| `radiusLg` | 16 | Cards, sections |
| `radiusXl` | 24 | Hero sections |
| `radiusFull` | 999 | Avatars, pills, decorative blobs |

---

## App Layout

### Bottom Navigation

The mobile app uses a **bottom navigation bar** as the primary navigation (replaces the web sidebar).

**5 tabs:**

| Tab | Icon (lucide) | Route |
|---|---|---|
| Home | `LucideIcons.home` | `/` |
| Newsfeed | `LucideIcons.newspaper` | `/newsfeed` |
| Games | `LucideIcons.target` | `/games` |
| Messages | `LucideIcons.messageCircle` | `/messages` |
| Profile | `LucideIcons.user` | `/profile` |

**Spec:**
- Height: 64dp + safe area inset (use `SafeArea`)
- Background: `bgSurface`
- Top border: 1px `borderDefault`
- Active tab: accent icon + accent label, others: `textTertiary`
- Use `BottomNavigationBar` with `type: BottomNavigationBarType.fixed` (no shifting)
- Persistent across all main screens, hidden on auth screens (login/signup)

### Drawer (secondary navigation)

A drawer (slide from left) houses less-frequent sections:

- Chatter
- Media (Videos / Splits / Albums)
- Events
- Cards
- Teams
- Notifications
- Dashboard
- Leaderboard
- Search
- Settings
- Sign Out

**Open via:** hamburger icon in the top app bar (only on Home tab) OR swipe from left edge.

### Top App Bar

- Height: 56dp
- Background: `bgPrimary` (transparent over content)
- Title: page name (or app logo on Home)
- Leading: hamburger (Home tab) or back arrow (other screens)
- Actions: search icon, notifications icon (with unread badge)
- No elevation/shadow — use a 1px bottom border instead

### Floating XP Bubbles (Global Overlay)

When the WebSocket sends `{"type": "xp_gained", "delta": 50}`, animate a floating bubble at the top of the screen.

- Shape: pill/blob with accent background (`#8bc342`), white text `+50 XP`
- Size: 60×40dp
- Spawn position: random horizontal (15-85% of screen width), starting just below the app bar
- Animation: rises 220dp upward in a slight zigzag, 1.4s duration, fades out at the top
- Max 3 visible at a time, stagger by 100ms
- Merge identical gains within 500ms (don't show two `+10 XP` bubbles in a row, show `+20 XP`)
- Toggle via setting `bn_xp_bubbles_enabled` (default on)

Implement as a top-level `Stack` overlay above the navigator. Listen to the notifications WS stream from a global Riverpod provider.

---

## Component Patterns

### AppButton

The single source of button styling. Never use raw `ElevatedButton` or `TextButton` with custom styles.

**Variants:**
- `primary` — accent background, white text, shadow glow on press
- `secondary` — transparent background, accent border, accent text
- `ghost` — no background/border, accent text only
- `destructive` — red background, white text
- `iconOnly` — square button with just an icon

**Sizes:**
- `small` — 36dp height, 12sp text
- `default` — 44dp height, 13sp text
- `large` — 48dp height, 14sp text

**Touch target minimum:** 44dp. Even small buttons get a 44dp tap area via `Material(child: InkWell(...))` or invisible padding.

**Loading state:** Replace text with `CircularProgressIndicator(strokeWidth: 2)` at 16dp. Disable button during load. Width stays fixed (no layout shift).

```dart
AppButton(
  variant: AppButtonVariant.primary,
  size: AppButtonSize.default_,
  loading: isSubmitting,
  onPressed: () => submit(),
  icon: LucideIcons.plus,
  child: Text('Create Post'),
)
```

### AppInput

```dart
AppInput(
  controller: emailController,
  label: 'Email Address',
  placeholder: 'you@example.com',
  errorText: error,
  prefixIcon: LucideIcons.mail,
)
```

**Spec:**
- Height: 48dp
- Background: `bgSurface`
- Border: 1px `borderStrong`, becomes `accent` on focus
- Border radius: 12dp
- Padding: 12dp horizontal
- Text size: 14sp
- Focus indicator: accent border + 3dp accent glow box-shadow (use `BoxShadow(blurRadius: 0, spreadRadius: 3, color: accentGlow)`)
- Error state: red border + red helper text below

### AppCard

```dart
AppCard(
  onTap: () => navigate(),
  showCornerOrb: true,
  child: Column(...),
)
```

**Spec:**
- Background: `bgSurface`
- Border: 1px `borderDefault`
- Border radius: 16dp
- Padding: 16dp on mobile (NEVER 20+ on mobile — eats too much space)
- Press feedback: `InkWell` ripple, no scale animation
- Optional corner orb: 112dp circle, accent at 5% opacity, positioned half-out at top-right

### BentoCard (Overview-style cards)

```dart
BentoCard(
  icon: LucideIcons.newspaper,
  iconColor: Colors.green, // section accent
  title: 'Newsfeed Highlights',
  onViewAll: () => router.go('/newsfeed'),
  child: ...,
)
```

**Spec:**
- Wraps `AppCard`
- Header: 32×32 icon container with `iconColor` at 15% opacity background, 16sp title, "View All →" link at right (11sp, `textTertiary`, becomes `accent` on tap)
- Content area: feature-specific (uses provided child)
- Built-in skeleton loader (controlled by `loading` prop)
- Built-in error state (controlled by `error` prop)

**Section accent colors** (matches web):

| Section | Color |
|---|---|
| Newsfeed | green |
| Chatter | blue |
| Media | purple |
| Events | orange |
| Leaderboard | yellow |
| Cards | pink |

### UserChip

The standard user-display widget. Used everywhere a user appears.

```dart
UserChip(
  user: user,
  size: UserChipSize.standard,
  showFollow: true,
  showXpBadge: true,
  onTap: () => router.push('/profile/${user.username}'),
)
```

**Sizes:**
- `compact` — 28dp avatar (used in comments)
- `standard` — 36dp avatar (used in posts, feed rows)
- `large` — 48dp avatar (used in profile headers, leaderboard top entries)

**Layout:**
```
[Avatar] [Username + XP Badge]   [Follow Button]
```

- Avatar: circular `CircleAvatar` with cached network image, fallback to accent circle with initials
- Username: 14sp, w600
- XP Badge: pill, `accentSubtle` background, accent text, 10sp
- Follow button: `LucideIcons.userCheck` (following) or `LucideIcons.userPlus` (not following), accent or tertiary tint, separate tap target

### XpBadge

```dart
XpBadge(level: 14, rank: 'Bronze')
```

**Spec:**
- Pill shape: 8dp horizontal padding, 2dp vertical
- Background: `accentSubtle`
- Text: 10sp, w600, accent color
- Border radius: full

### Bottom Sheets (Modals)

**Always prefer bottom sheets over center dialogs on mobile.** Center dialogs are harder to reach with one hand.

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => AppBottomSheet(
    title: 'Report Post',
    child: ...,
  ),
);
```

**Spec:**
- Background: `bgSurfaceElevated`
- Border radius: 16dp top corners only (`BorderRadius.vertical(top: ...)`)
- Drag handle: 32×4dp pill at top, `borderStrong` color
- Padding: 24dp content
- Backdrop: black 60% opacity + 4px blur (use `BackdropFilter`)
- Entry: slide up + fade, 200ms `Curves.easeOutCubic`
- Dismiss: drag down, tap backdrop, system back

### Toast / Snackbar

Use a custom toast widget at the bottom of the screen, ABOVE the bottom navigation bar.

**Spec:**
- Background: `bgSurfaceElevated`
- Border radius: 14dp
- Left border: 3dp accent (info), success (green), error (red), warning (orange)
- Padding: 16dp
- Auto-dismiss: 4 seconds
- Entry: slide up + fade, 200ms
- Position: 16dp above bottom nav, centered horizontally
- Max 1 visible at a time (queue if multiple)

### Section Headers

**Uppercase label (default):**
```dart
Text(
  'POPULAR DISCUSSIONS',
  style: AppTextStyles.label(context),
)
```

**Icon + title (for featured sections):**
```dart
Row(
  children: [
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(LucideIcons.users, size: 14, color: accent),
    ),
    SizedBox(width: 10),
    Text('Suggested Users', style: AppTextStyles.sectionTitle(context)),
  ],
)
```

### Empty States

```dart
EmptyState(
  icon: LucideIcons.inbox,
  title: 'No notifications yet',
  hint: "We'll let you know when something happens",
)
```

**Spec:**
- Centered vertically
- Icon: 24sp, `textTertiary`
- Title: 13sp, w500, `textSecondary`
- Hint: 12sp, `textTertiary`
- Padding: 32dp top/bottom

### Skeleton Loaders

Use `shimmer` package. Build skeletons that match the shape of incoming content.

```dart
SkeletonBox(width: double.infinity, height: 80, radius: 16)
```

**Spec:**
- Base color: `bgSurface`
- Highlight color: `bgSurfaceHover`
- Animation duration: 1500ms
- Direction: left to right

**Pattern:** Always use a list of skeletons (3-5 items) to fill the visible area. Never use a single spinner for page loads.

### List Items (Feed Rows)

Compact horizontal layout, used for notification rows, message previews, etc.

```
[Avatar]  [Title]              [Timestamp]
          [Subtitle]
```

**Spec:**
- Padding: 12dp horizontal, 10dp vertical
- Border radius: 12dp on press feedback (`InkWell`)
- Avatar: 32-36dp circle
- Title: 14sp, w500
- Subtitle: 12sp, `textSecondary`, single line truncated
- Timestamp: 11sp, `textTertiary`, right-aligned
- Hover/press: `bgSurfaceHover` overlay at 40% opacity

---

## Visual Tokens Quick Reference

### Shadows (Flutter `BoxShadow`)

| Usage | Spec |
|---|---|
| CTA button | `BoxShadow(color: accent.withOpacity(0.25), blurRadius: 16, offset: Offset(0, 4))` |
| CTA pressed | `BoxShadow(color: accent.withOpacity(0.35), blurRadius: 20, offset: Offset(0, 6))` |
| Card press | `BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 4))` |
| Focus ring | `BoxShadow(color: accentGlow, blurRadius: 0, spreadRadius: 3)` |

### Opacity Scale for Accent Overlays

| Opacity | Usage |
|---|---|
| 5% | Decorative blur blobs, corner orbs (subtle) |
| 10% | Hero gradient start, hover state |
| 15% | Icon containers, badge backgrounds |
| 20% | Active borders |
| 25% | CTA glow shadow |

---

## Responsive & Device Considerations (CRITICAL)

The app must look good on:
- **Smallest target:** iPhone SE (320dp wide × 568dp tall) and small Android (360×640)
- **Standard:** iPhone 14/15 (390-393dp wide), Pixel (411dp wide)
- **Large phones:** iPhone Pro Max (430dp wide)
- **Tablets:** iPad (768dp+ wide) — see Tablet section

### Phone (default)

1. **Single column always.** Multi-column only on tablet (`MediaQuery.sizeOf(context).width > 600`).
2. **Edge-to-edge cards** with 16dp side padding from screen edges.
3. **Touch targets minimum 44dp.** All buttons, icons, list rows.
4. **Safe areas respected.** Use `SafeArea` widget. Account for notches, dynamic island, gesture bar.
5. **Keyboard handling.** Use `resizeToAvoidBottomInset: true` (default). Scroll-to-input on focus. Use `KeyboardVisibilityBuilder` for layout adjustments.

### Tablet (>600dp width)

1. **Two-column layouts permitted.** Newsfeed shows feed + sidebar. Messages shows conversation list + thread.
2. **Wider content max-width:** Center content within 600dp on tablets, don't stretch full width.
3. **Persistent drawer** instead of overlay drawer.
4. **Larger touch targets fine** (still 44dp minimum, but 48dp+ for primary actions).

### Mobile-First Checklist

After building any screen, ask:
- Does this look intentional on a 320dp screen?
- Do all touch targets meet 44dp?
- Is text legible at minimum sizes (no smaller than 11sp)?
- Are buttons reachable with one thumb?
- Does the keyboard not obscure the input?
- Does it handle being rotated to landscape (if portrait-only is not enforced)?

---

## Platform-Specific Considerations

### iOS

- Use `CupertinoPageTransitionsBuilder` for navigation (slide from right with parallax).
- Status bar style: `SystemUiOverlayStyle.light` on dark theme, `dark` on light theme.
- Haptic feedback on key actions: `HapticFeedback.lightImpact()` on tap, `mediumImpact()` on success, `heavyImpact()` on error.
- Pull-to-refresh: use `CupertinoSliverRefreshControl` inside `CustomScrollView`.

### Android

- Use `OpenUpwardsPageTransitionsBuilder` or `ZoomPageTransitionsBuilder` for navigation.
- System back button: handle with `WillPopScope` or `PopScope`.
- Edge-to-edge display: enable via `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`.
- Pull-to-refresh: use `RefreshIndicator` (Material).
- Status bar/nav bar colors: match `bgPrimary`.

### Both

- Respect system dark mode by default (`ThemeMode.system`).
- Respect system font size scaling — but cap text scale at 1.3x to prevent layout breakage (`MediaQuery.withClampedTextScaling`).
- Respect reduced motion (`MediaQuery.disableAnimations`).

---

## Anti-Patterns (What NOT to Do)

1. **Never use raw colors.** Always pull from `AppColors` or `Theme.of(context).colorScheme`. No `Color(0xFF...)` in widget files.
2. **Never use raw font sizes.** Use `AppTextStyles`. No `TextStyle(fontSize: 14)` inline.
3. **Never use ElevatedButton/TextButton with custom styles.** Use `AppButton`. Always.
4. **Never use full-screen `CircularProgressIndicator` for page loads.** Use shimmer skeletons.
5. **Never animate width, height, padding, or margin.** Only `transform` and `opacity`. Use `AnimatedOpacity`, `AnimatedScale`, `Transform.translate` with `AnimationController`.
6. **Never use accent color for body text.** Accent is for actions and indicators only.
7. **Never hardcode pixel values for spacing.** Use `AppSpacing` constants.
8. **Never use `showDialog` for primary modals on mobile.** Use `showModalBottomSheet`. Dialogs are only for confirmations (delete, sign out, etc.).
9. **Never let touch targets fall below 44dp.** Even decorative icons that are tappable get a 44dp invisible padding.
10. **Never use `MediaQuery.of(context).size` to make decisions inside build.** Use `LayoutBuilder` for layout-dependent rendering.
11. **Never block the UI thread with sync work.** All file I/O, parsing, image processing must be async (use `compute()` for heavy work).
12. **Never use `setState` in deeply nested widgets.** Use Riverpod `ref.watch` for state.
13. **Never display backend errors as a single string.** Iterate the `errors` array and show each message.
14. **Never use system fonts directly.** Use Geist with system fallback so the brand identity carries.
15. **Never skip `tabular-nums` on number displays.** Misaligned numbers during animation look broken.
16. **Never ignore the safe area.** Use `SafeArea` or apply `MediaQuery.padding` manually.
17. **Never place tappable elements behind the bottom navigation bar.** Add bottom padding to scrollable content equal to nav bar height.
18. **Never assume network success.** Every API call has loading, success, AND error states. The error state is not optional.
19. **Never lock orientation without reason.** Default to portrait + landscape on tablet, portrait-only on phone is acceptable.
20. **Never use Flutter's default Material theme.** Configure `ThemeData` explicitly with the BowlersNetwork tokens.

---

## Brand Assets

| Asset | URL / Location |
|---|---|
| Logo (light/dark variant) | `https://logos.bowlersnetwork.com/bn_logo_2026.png` |
| App icon | Generated from logo, square + rounded variants |
| Splash screen | Logo centered on `bgPrimary`, 200dp logo width |
| Title rendering | "Bowlers" in `textPrimary`, "Network" in `accent` (#8bc342) |

**App title format:** `BowlersNetwork` (one word, capital N).

---

## Reference Screens

When in doubt about a pattern, study the equivalent web screen for visual reference. The web frontend lives at `https://bb.bowlersnetwork.com` (staging). The mobile app should feel like a native version of the same product — same hierarchy, same color logic, same component philosophy, but adapted to mobile interaction patterns (bottom sheets, tab bar, gesture-based navigation).
