# BowlersNetwork — Mobile App System Knowledge

You are building the BowlersNetwork mobile app in Flutter. This skill contains the complete system context for the mobile client. Apply it to every task.

For platform context, load `system-knowledge`. For visual design, load `ui-ux-design`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod 2.x (preferred) or Bloc — pick one and stick with it |
| Navigation | go_router |
| HTTP Client | dio (with interceptors for auth + error handling) |
| WebSocket | web_socket_channel |
| Local Storage | flutter_secure_storage (tokens), shared_preferences (preferences) |
| Image Caching | cached_network_image |
| Image Picking | image_picker |
| Image Cropping | image_cropper |
| Push Notifications | firebase_messaging (FCM for both iOS + Android) |
| Maps | flutter_map (Mapbox tiles) or google_maps_flutter |
| Charts | fl_chart |
| Date/Time | intl + timeago |
| Icons | lucide_icons (matches web app convention exactly) |
| Skeletons | shimmer |
| File Upload | dio + http multipart for R2 presigned URLs |
| Video Player | video_player + chewie |

**Target platforms:** iOS 14+, Android API 24+ (Android 7.0+).

---

## Architecture

### Layered structure

```
lib/
├── main.dart
├── app.dart                         # MaterialApp.router setup
├── core/
│   ├── api/                         # Dio client, interceptors, base config
│   │   ├── api_client.dart
│   │   ├── auth_interceptor.dart
│   │   └── error_interceptor.dart
│   ├── auth/                        # Token storage, JWT decode, auth state
│   ├── routing/                     # go_router config + auth guards
│   ├── theme/                       # ThemeData, ColorScheme, ThemeExtensions
│   ├── websocket/                   # WS connection managers
│   └── constants/                   # API URLs, app-wide constants
├── features/
│   ├── access/                      # Login, signup flow
│   ├── newsfeed/
│   ├── profile/
│   ├── chatter/
│   ├── media/
│   ├── games/
│   ├── teams/
│   ├── events/
│   ├── cards/
│   ├── messages/
│   ├── notifications/
│   ├── dashboard/
│   ├── search/
│   └── xp/
├── shared/
│   ├── widgets/                     # UserChip, BentoCard, AppButton, etc.
│   ├── models/                      # Cross-feature DTOs
│   └── utils/                       # Formatters, helpers
└── gen/                             # Generated assets (Geist font, images)
```

### Per-feature structure

Each feature in `features/` follows the same shape:

```
features/newsfeed/
├── data/                            # API calls, repository
│   ├── newsfeed_repository.dart
│   └── models/                      # DTOs that mirror backend response shapes
├── application/                     # Riverpod providers, controllers
│   └── feed_controller.dart
└── presentation/                    # Widgets, screens
    ├── screens/
    │   ├── feed_screen.dart
    │   └── post_detail_screen.dart
    └── widgets/
        ├── post_card.dart
        └── reaction_bar.dart
```

The feature directory is self-contained. Cross-feature dependencies flow through `shared/` only.

---

## API Integration

### Base configuration

```dart
const apiBaseUrl = 'https://backend.bowlersnetwork.com';
```

Store as a build-time constant (`--dart-define=API_BASE_URL=...`), never hardcode in feature code.

### Dio client setup

- One `Dio` instance per app, injected via Riverpod provider.
- `connectTimeout: 10s`, `receiveTimeout: 30s`.
- Add interceptors: `AuthInterceptor` (attaches Bearer token), `ErrorInterceptor` (parses backend `{"errors": [...]}` shape into typed `ApiException`).

### Response shape contract

**Success:** Direct JSON — object, array, or value.

**Error (4xx/5xx):** Always `{"errors": ["Message 1.", "Message 2."]}` — `errors` is **always** a list of strings.

The `ErrorInterceptor` should parse this into:

```dart
class ApiException implements Exception {
  final int statusCode;
  final List<String> messages;
  ApiException(this.statusCode, this.messages);
}
```

Never display a single concatenated error string. Always iterate `messages` in the UI so the user sees every issue.

### Pagination

- **Offset-based** (most list endpoints): `?page=1&page_size=20`
- **Cursor-based** (feeds): `?cursor=<opaque>` — backend returns `next_cursor` in response

The mobile app should support infinite scroll on feeds via cursor pagination, and pull-to-refresh on every list screen.

### Parallel requests

When a screen needs multiple endpoints (e.g., the Overview screen pulls 9 endpoints), fire them in parallel:

```dart
final results = await Future.wait([
  api.getXpLevelInfo(),
  api.getNewsfeedHighlights(),
  api.getSponsors(),
  // ...
], eagerError: false);
```

Use `eagerError: false` so one failure doesn't break the screen — render partial state with skeleton fallbacks for failed sections.

---

## Authentication

### Token storage

- JWT stored in `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android).
- Token includes a `gate` claim (`base` or `pro` for mobile users).
- Token lifetime: 30 days. The backend will return 401 when expired — the app routes to login.

### Auth flow

1. **Login screen:** username/email + password → `POST /api/auth/login` → store token.
2. **Login response check:**
   - If `requires_consent: true` → navigate to consent-pending screen (locked).
   - Else → check profile completion via `GET /api/profile/completion`.
3. **Profile completion check:**
   - If `is_complete: false` → navigate to profile completion screen (locked, must complete).
   - Else → navigate to home (overview screen).

### Auth guard (go_router redirect)

```dart
GoRouter(
  redirect: (context, state) {
    final auth = ref.read(authStateProvider);
    if (!auth.isAuthenticated) return '/login';
    if (auth.requiresConsent) return '/consent-pending';
    if (!auth.profileComplete && !isExemptRoute(state.location)) return '/profile';
    return null;
  },
);
```

Exempt routes (accessible with incomplete profile): `/profile`, `/profile/edit`, `/settings`, `/consent-pending`.

---

## WebSocket Connections

Two app-level connections, both opened on login and closed on logout.

| Path | Purpose |
|---|---|
| `wss://backend.bowlersnetwork.com/ws/notifications/?token={jwt}` | Notifications + XP gain events |
| `wss://backend.bowlersnetwork.com/ws/chat/?token={jwt}` | Chat messages + typing indicators |

**Connection management:**
- Auto-reconnect with exponential backoff (1s, 2s, 4s, 8s, max 30s).
- Reconnect on app foreground (use `WidgetsBindingObserver`).
- Show a subtle banner if disconnected for > 5 seconds.

**XP bubble events:**

The notifications WS receives `{"type": "xp_gained", "delta": 50}` events. These trigger floating XP bubbles globally (see `ui-ux-design` for visual spec). The bubble system lives in a top-level overlay, not inside any screen.

---

## Push Notifications (FCM)

- Register FCM token on login → `POST /api/notifications/devices/register` with `{token, platform: "ios"|"android"}`.
- Unregister on logout → `POST /api/notifications/devices/unregister`.
- Handle foreground notifications via local notifications (flutter_local_notifications) — show in-app banner.
- Handle background notifications via system notification — tapping deep-links to the relevant screen.
- Deep link payload format: `{"route": "/newsfeed/post_uid"}`.

---

## File Upload Flow (R2)

Same flow as web. The mobile app does NOT proxy uploads through the backend — files go directly to R2 via presigned URLs.

```
1. POST /api/cloud/upload/singlepart/requests/initiate
   Body: {filename: "photo.jpg", content_type: "image/jpeg"}
   Response: {upload_url: "...", key: "...", public_url: "..."}

2. PUT bytes to upload_url (presigned R2 URL, expires in minutes)
   Headers: Content-Type: image/jpeg
   Body: file bytes

3. Use public_url in subsequent API calls (e.g., updating profile picture)
```

For large videos, use multipart upload endpoints (`/api/cloud/upload/multipart/requests/...`).

**Upload progress:** Use Dio's `onSendProgress` callback to drive a progress UI.

---

## Routing (go_router)

| Route | Screen | Auth |
|---|---|---|
| `/login` | Login | No |
| `/signup` | Multi-step signup | No |
| `/consent-pending` | Parental consent waiting | Yes (locked) |
| `/` | Overview | Yes |
| `/newsfeed` | Newsfeed | Yes |
| `/newsfeed/:postUid` | Post detail | Yes |
| `/chatter` | Discussions list | Yes |
| `/chatter/discussions/:uid` | Discussion detail | Yes |
| `/media` | Media (videos + splits) | Yes |
| `/media/videos/:uid` | Video player | Yes |
| `/media/splits/:uid` | Split player | Yes |
| `/games` | Game tracking | Yes |
| `/teams` | Teams list | Yes |
| `/teams/:teamId` | Team detail | Yes |
| `/events` | Events calendar | Yes |
| `/events/:uid` | Event detail | Yes |
| `/cards` | Cards feed + collections | Yes |
| `/cards/:cardUid` | Card detail | Yes |
| `/messages` | Conversations | Yes |
| `/messages/:conversationUid` | Chat thread | Yes |
| `/notifications` | Notifications list | Yes |
| `/dashboard` | User analytics | Yes |
| `/search` | Universal search | Yes |
| `/profile` | Own profile (editable) | Yes |
| `/profile/:username` | Other user's profile | Yes |
| `/settings` | App settings | Yes |
| `/leaderboard` | XP leaderboard | Yes |

---

## State Management (Riverpod)

### Provider categories

- **Auth state:** `authStateProvider` (StateNotifier) — token, user, gate, profile completion
- **API client:** `apiClientProvider` (Provider) — Dio instance
- **Repository providers:** One per feature, depend on `apiClientProvider`
- **Controller providers:** One per screen, depend on repositories — handle screen-level state (loading, error, data)
- **WebSocket providers:** `notificationsWsProvider`, `chatWsProvider` — StreamProviders

### Pattern

Screens depend on controllers. Controllers depend on repositories. Repositories depend on the API client. Never call the API directly from a widget.

---

## Offline Behavior

- Mobile app is **online-first**. No offline mode.
- All data fetches require network. On no-connectivity, show a retry banner — never silently fail.
- Cache only what improves UX: avatars, post images (cached_network_image), the last-loaded feed for instant render on app reopen.
- Never cache mutations. If the user posts/comments offline, show an error and let them retry — never queue.

---

## Performance Targets

| Metric | Target |
|---|---|
| Cold start to first frame | < 1.5s |
| Cold start to interactive | < 3s |
| Scroll FPS | 60 (jank-free) |
| Image load (cached) | < 100ms |
| API P95 response | < 600ms (backend SLA) |
| App size (release APK) | < 25 MB |

**Build flags:**
- Release builds use `--obfuscate --split-debug-info`.
- Tree-shake icons (`--tree-shake-icons`).
- Defer initialization of non-critical services (analytics, crash reporting) until after first frame.

---

## Animation Principles

- **Fast and purposeful.** 150-250ms for micro-interactions, 300ms max for screen transitions.
- **Easing:** `Curves.easeOutCubic` for entries, `Curves.easeIn` for exits.
- **Only animate transform and opacity.** Use `AnimatedOpacity`, `AnimatedScale`, `AnimatedSlide`, `AnimatedPositioned` — never animate `width`, `height`, `padding`, or `margin` directly.
- **Respect reduced motion:** Check `MediaQuery.of(context).disableAnimations` and skip non-essential animations.
- **Skeleton loaders everywhere.** Never use full-screen `CircularProgressIndicator` for page loads — use shimmer skeletons that match the shape of incoming content.

---

## Content Formatting

Match the web app's conventions exactly so the experience feels consistent.

**Timestamps (use timeago):**
- < 1 minute: "Just now"
- < 1 hour: "5m ago"
- < 24 hours: "3h ago"
- < 7 days: "2d ago"
- Older: "Mar 12, 2026"
- Long-press: show full datetime tooltip

**Numbers:**
- < 1,000: exact ("847")
- 1,000 - 999,999: abbreviated ("1.2K", "47.3K")
- 1,000,000+: abbreviated ("1.2M", "23.5M")
- XP and game scores: always exact with thousands separator ("12,847")

**Truncation:**
- Post captions: 3 lines + "Read more"
- Discussion titles: 2 lines + ellipsis
- Usernames: never truncate

---

## Shared Widgets to Build Early

Build these once, use everywhere. They map directly to the design system:

| Widget | Purpose |
|---|---|
| `AppButton` | Primary/secondary/ghost/destructive variants. The single source of button styling. |
| `AppInput` | Text field with consistent border, focus ring, error state |
| `AppCard` | Standard card with surface bg, border, optional corner orb |
| `BentoCard` | Overview-style card with icon container, title, "View All" link |
| `UserChip` | Avatar + username + XP badge + follow button (compact/standard/large) |
| `XpBadge` | Pill with level/rank, accent-subtle bg |
| `SkeletonBox` | Shimmer rectangle for loading states |
| `EmptyState` | Icon + primary message + secondary hint |
| `AppBottomSheet` | Modal bottom sheet with consistent styling |
| `AppDialog` | Centered dialog (use only when truly needed — prefer bottom sheets on mobile) |
| `Toast` | Snackbar replacement with accent/success/error variants |
| `XpBubbleOverlay` | Top-level overlay for XP gain animations |

---

## Profile Completion Gate

The single most important UX rule: users with incomplete profiles cannot access ANY feature. The router redirects them to `/profile` and the bottom navigation is locked (or hidden) until `GET /api/profile/completion` returns `is_complete: true`.

The profile screen shows a top banner with:
- Progress bar (% complete)
- List of missing fields
- Highlight each missing field inline as the user fills them

Once complete, the banner disappears, navigation unlocks, and the user is redirected to home.

---

## Pro Player Mode

Some users have `is_pro: true` (read from the user object after login or `/api/profile`). This unlocks Pro-only views and features:

- A "Pro" badge on their profile
- Access to Pro-only sections (e.g., enhanced analytics)
- Pro-specific entries in navigation

The same app handles both regular and Pro users — no separate build, no separate auth flow. Just conditional UI based on `is_pro`.

---

## Reporting & Moderation

All user-generated content must be reportable from a long-press or "..." menu. Report flow:

1. Tap "Report" on any post, comment, video, etc.
2. Show a bottom sheet with reason categories (spam, harassment, inappropriate, etc.)
3. Submit to `POST /api/report` with `{content_type, content_id, reason}`
4. Show toast confirmation

This must work consistently across every content type — wire it once in a shared `ReportSheet` widget.

---

## API Documentation

Backend API docs are in `~/Documents/bn_v2_frontend_docs/` (request from Mumit Boss if not present). One markdown file per system: access, profiles, brands, centers, search, events, cards, reporting, messages, teams, games, xp, dashboard, notifications, newsfeed, chatter, media, cloud.

These are the **source of truth** for endpoint contracts. The web frontend uses the same docs. If anything is unclear, ask before assuming.
