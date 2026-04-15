# BowlersNetwork — Platform Overview

This is the platform-level orientation for the BowlersNetwork mobile app. It covers what the platform is, how it's structured, and what the mobile app fits into. Load this first.

For Flutter-specific stack and architecture, load `app-knowledge`. For UI/UX design language, load `ui-ux-design`.

---

## What Is BowlersNetwork

A social-sports platform built for the bowling community — amateur bowlers, professional players, fans, coaches, center operators, and industry stakeholders. It combines social networking, gamification, competitive analytics, and community discussion into a single ecosystem.

Bowling is structural, not cosmetic. The data models, features, and interactions are built around bowling-specific concepts: centers, game scores, ball handling styles, lane conditions, tournaments, leagues, and the physical geography of where people bowl.

---

## Architecture

**One centralized backend serving multiple frontends and a mobile app.**

| Client | Platform | Users | Access |
|---|---|---|---|
| **Base Web** | Next.js (bowlersnetwork.com) | All users + Pro Players | Public signup |
| **Mobile App** | Flutter (iOS + Android) | All users + Pro Players | Public signup |
| **Centers Web** | Next.js (centers.bowlersnetwork.com) | Center admins | Staff-created |
| **Office Web** | Next.js (office.bowlersnetwork.com) | Internal staff | CRM/admin |

The backend is a Django application exposing a REST API + WebSocket endpoints. The mobile app talks to the same backend as the web frontends. Authentication is gate-scoped: JWT tokens carry a `gate` claim, and the backend enforces it.

**API Base URL:** `https://backend.bowlersnetwork.com`

The mobile app uses `gate=base` for regular users and `gate=pro` for Pro Players (gate is selected at login, not signup).

---

## Core Systems

The mobile app integrates with all of these. Each is a major feature surface:

| System | Description |
|---|---|
| **Identity & Auth** | Custom User model, gate-scoped JWT, structural roles (Pro Player, Center Admin, Staff are separate models with OneToOneField to User) |
| **Profiles** | 12+ profile sub-models, completion gate, follow system, favorite brands |
| **XP & Ranks** | Points, levels (1-50), ranks, tiers, badges, streaks, leaderboards, real-time XP gain bubbles via WebSocket |
| **Newsfeed** | Posts (text, photo, video, score, poll, share), reactions, comments, saves |
| **Chatter** | Forum discussions, opinions, upvote/downvote, topics, tags, credibility scoring |
| **Media** | Videos, splits (short clips ≤90s), albums, images, playlists, channels |
| **Games** | Frame-by-frame bowling game tracking, sessions, pin leave analysis |
| **Teams** | Team creation, invitation system, auto-provisioned group chat |
| **Events** | Event management, interest/going, invitations, notes, calendar |
| **Cards** | Digital trading cards with HTML rendering, designs, likes, collections |
| **Messages** | Direct and group conversations, real-time via WebSocket |
| **Notifications** | In-app + WebSocket delivery + push (FCM/APNs) |
| **Dashboard** | User analytics, engagement insights, monthly game reports |
| **Search** | Elasticsearch-powered central and scoped predictive search |

---

## User Classes

Role is structural — separate models with OneToOneField to User. Checking role = checking record existence on backend, but for the mobile app it's exposed via fields like `is_pro` on the user object.

| Class | Backend Model | Mobile App Behavior |
|---|---|---|
| User (Base) | `player.User` | Default. All public signups. |
| Pro Player | `entrance.Pro` (OneToOne User) | Same app, but `is_pro: true` unlocks Pro-only features and views. Gate = `pro`. |
| Center Admin | `centers.CenterAdmin` (OneToOne User) | Not supported in mobile app (web only). |
| Staff | `office.Staff` (OneToOne User) | Not supported in mobile app (web only). |

---

## Key Concepts the Mobile App Must Understand

**Auto-provisioning:** Every user gets 14+ dependent records on creation (Profile, XP, CredibilityScore, etc.). The mobile app never needs to "initialize" anything after signup — all profile fields exist and can be read/updated immediately.

**Profile completion gate:** Users must complete their profile before accessing platform features. The mobile app must check `GET /api/profile/completion` after login and lock navigation until complete. Exempt routes: profile screen, settings, consent-pending screen.

**Parental consent:** Minors (13-17) can sign up but their account is restricted until a parent grants consent via an email link. The login response includes `requires_consent: true` for minors with pending consent — the app shows a locked consent-pending screen.

**Real-time:** Two WebSocket connections at app level — notifications (with XP gain events) and chat. Both should reconnect automatically.

**Content polymorphism:** Likes, saves, views, and reports work across multiple content types (posts, videos, splits, albums, cards, etc.) via `(content_type, content_id)` references.

**Pagination:** Backend uses offset-based pagination for ordered lists and cursor-based for feeds. Always check the API doc for which endpoint uses which.

---

## API Patterns the Mobile App Must Follow

**Success response:** `{"field": "value"}` — direct JSON object or array.

**Error response:** Always `{"errors": ["Message 1.", "Message 2."]}` — `errors` is ALWAYS an array of strings, even for a single error. The mobile app must iterate the array to display each message — never assume a single error.

**Auth header:** `Authorization: Bearer {token}` on every authenticated request.

**Parallel calls:** When a screen needs multiple endpoints, fire them in parallel (use `Future.wait` with `eagerError: false` to handle partial failures).

---

## Platform Boundaries

- The mobile app does NOT replace the web frontends — it complements them. Users may sign up on web and log in on mobile, or vice versa.
- The mobile app does NOT have its own backend. All logic lives in the centralized Django backend.
- The mobile app does NOT cache business logic. Validation, permissions, and computations are backend-owned. The app trusts what the backend returns.
- Pro Players use the same app as regular users. A `is_pro` flag in the user object unlocks Pro-only sections.
