# JGive Assignment — Eliya Duek

A fundraising campaign clone inspired by [JGive](https://www.jgive.com/new/he/ils/donation-targets/159183).
Built with Ruby on Rails 8.1, SQLite3 (dev) / PostgreSQL (Render), Hebrew RTL layout, Tailwind CSS via CDN, and Heebo font.

---

## 1. Running Locally

**Prerequisites:** Ruby 3.2.x, Bundler (`gem install bundler`)

```bash
# 1. Install gems
bundle install

# 2. Create and migrate the database
ruby bin/rails db:create db:migrate

# 3. Seed the four demo campaigns
ruby bin/rails db:seed

# 4. Start the server
ruby bin/rails server
# → http://localhost:3000
```

> **Windows:** prefix all `bin/rails` commands with `ruby` (e.g. `ruby bin/rails …`).

To **re-seed** (truncates all existing data):

```bash
ruby bin/rails db:seed
```

---

## 2. Seed Campaigns

Four campaigns are seeded to demonstrate every progress-bar state:

| # | Campaign | Goal | Bonus goal | Raised | Bar state |
|---|----------|------|-----------|--------|-----------|
| 1 | קרן מלגות לסטודנטים מצטיינים | ₪2,000,000 | ₪5,000,000 | ~₪1.07M | ~53% — purple fill, below main goal |
| 2 | בנק המזון ירושלים | ₪750,000 | — | ~₪487K | 65% — single green bar |
| 3 | רכישת ציוד רפואי לבית חולים שיבא | ₪1,000,000 | ₪3,000,000 | ~₪1.75M | 175% — purple past main goal |
| 4 | הגן הכתום — לזכר בני משפחת ביבס | ₪2,000,000 | ₪3,000,000 | ~₪1.08M | ~54% — purple fill |

---

## 3. Architecture

### Models

| Model | Key columns |
|-------|-------------|
| `Campaign` | `title`, `slogan`, `description`, `story`, `goal_amount_cents`, `bonus_goal_amount_cents` (nil = single-goal), `cover_image_url`, `video_url` |
| `Donation` | `campaign_id`, `amount_cents`, `status` (pending/paid/failed), `frequency` (one_time/monthly), `display_preference`, `donor_name`, `dedication` |

**Campaign computed methods:** `total_raised_cents`, `donor_count`, `main_progress_percentage`, `has_bonus_goal?`, `display_donations`

### Controllers & Routes

| Route | Action | Notes |
|-------|--------|-------|
| `GET /` | `campaigns#index` | Card grid of all campaigns |
| `GET /campaigns/:id` | `campaigns#show` | Campaign page with tabs |
| `POST /campaigns/:id/donations` | `donations#create` | Creates a `pending` donation |

### Views

| File | Purpose |
|------|---------|
| `layouts/application.html.erb` | `lang="he" dir="rtl"` root, Heebo + Tailwind CDN, sticky header, language toggle, currency toggle |
| `campaigns/index.html.erb` | 2-column card grid; each card links to the campaign show page |
| `campaigns/show.html.erb` | Full-width click-to-play hero video, progress bar, tab navigation (Story / Updates / Donors), donation modal trigger |
| `donations/_form.html.erb` | Frequency toggle, preset grid, amount input, name/dedication fields |
| `shared/_empty_state.html.erb` | Reusable empty state (Story, Updates, Donors tabs) |

### Helpers (`app/helpers/application_helper.rb`)

| Helper | Purpose |
|--------|---------|
| `format_ils(cents)` | `₪1,065,630` |
| `youtube_embed_url(url)` | Converts watch URL → `/embed/ID` |
| `progress_bar_segments(campaign)` | Returns `{ type:, purple:, green_right:, heart_left: }` for dual-goal or `{ type:, fill: }` for single |

### Client-side JavaScript

All JS is inline (no Stimulus / Node / Webpack):

- **Donation modal** — `openDonationModal()` / `closeDonationModal()` triggered by the CTA button; auto-opens if a validation error is returned from the server.
- **Click-to-play hero** — thumbnail shown first; click captures the container height and replaces `innerHTML` with an autoplay iframe at the same pixel height.
- **Preset amount buttons** — toggle active state and populate the amount input.
- **Language toggle** — `localStorage`-persisted `is-en` class on `<html>`; FOUC-free inline head script.
- **Currency toggle** — fetches a live USD/ILS rate from frankfurter.app (cached 24 h in `localStorage`); swaps all `data-cents` spans between ₪ and $.

---

## 4. Progress Bar

**Domain:** `bonus_goal_amount_cents` if present; otherwise `goal_amount_cents`.

The bar uses `dir="ltr"` inside an RTL page so CSS `left:`/`width:` fills left-to-right.

| Segment | Color | Covers |
|---------|-------|--------|
| Purple | `#d426ff` | 0 → raised amount (capped at 100%) |
| Green | `#008043` | Main-goal threshold → right edge |
| Orange heart `♥` | `#f59e0b` | Floats at the left edge of the green zone (= main goal threshold) |

Single-goal campaigns show a simple green fill (no heart).

---

## 5. Payment Provider Wiring

Donations are created with `status: :pending` and stay there in this implementation.

### Stripe Checkout (recommended for international)

1. **`DonationsController#create`** — persist the donation (`status: :pending`), call `Stripe::Checkout::Session.create(...)` with `metadata[:donation_id]`, redirect donor to `session.url`.
2. **New `WebhooksController`** — verify the signature with `Stripe::Webhook.construct_event`, find the donation, call `donation.update!(status: :paid)`.
3. **Success redirect** — donor returns to `?donation=123`; reload the record and show "confirmed" or "processing" based on whether the webhook beat the redirect.
4. **Expired / failed** — handle `checkout.session.expired` by setting `status: :failed`; the progress bar already excludes failed donations from `total_raised_cents`.

### Israeli equivalents (Tranzila / Meshulam / PayPlus)

These use a **hosted page + callback URL** pattern: redirect → provider page → callback with a transaction token → verify via API → `donation.update!(status: :paid)`. The model change is identical; only the HTTP flow differs.

---

## 6. Key Decisions & Trade-offs

### Data layer

- **Integer cents** — avoids floating-point rounding. All display formatting is in the `format_ils` helper.
- **String enums** (`status`, `frequency`, `display_preference`) — readable in the SQLite file and in `rails console` without a lookup table.
- **`story` as plain `text` column** — Action Text scoped out; the column can later be swapped for an Action Text attachment without a model migration.

### Progress bar design

- **Purple from left, green from right** — mirrors the JGive reference. Domain is the bonus goal when present, so overflow (raised > main goal) naturally extends the purple into the green zone without special-casing.
- **Heart at main-goal threshold** — `heart_left = 100 - green_right`, so it always marks the main goal regardless of how much has been raised.

### Hero video

- **Click-to-play thumbnail** — avoids auto-loading a YouTube iframe (which blocks page render and is a privacy risk). The thumbnail height is captured before replacing `innerHTML` so the iframe renders at the exact same pixel size.
- **`cover_image_url` preferred over YouTube auto-thumbnail** — campaigns can supply their own cover image; YouTube thumbnail is only a fallback.

### Donation modal

- **Modal instead of a persistent sidebar** — cleans up mobile layout and matches how the reference site behaves at smaller breakpoints. Opens on CTA click; auto-opens if the form returns validation errors.
- **No Stimulus** — the modal open/close, preset buttons, and click-to-play are all inline IIFEs. Avoids adding `importmap-rails` + `stimulus-rails` gems (both require network access during `bundle install` and a build step).

### Tailwind via CDN

- `tailwindcss-rails` requires native-compiled binaries (MSYS2 on Windows) and a Node-backed build step. CDN works out of the box and is sufficient for a scope-limited assignment. Flagged for production swap.

### Server-rendered tabs

- `?tab=<name>` query param; no JS needed. The read-heavy show page doesn't benefit from client-side tab switching within this scope.

### Pending donations count toward progress

- `total_raised_cents` sums both `pending` and `paid` donations. Pending donations appear with an amber "ממתין לאישור" badge in the Donors tab. This matches JGive's behaviour (campaigns show momentum before payment clears).

---

## 7. What I'd Do With More Time

1. **Real payment integration** — Stripe Checkout webhook flow as described in §5. Add a `StripeWebhookJob` (Active Job + Sidekiq) so webhook processing is async and idempotent.

2. **Stimulus controllers** — replace inline IIFEs with named `tabs_controller`, `progress_bar_controller`, and `modal_controller` for testability and reuse across campaigns.

3. **Tailwind CSS gem** — replace the CDN `<script>` with `tailwindcss-rails` for a purged, production-optimised stylesheet and proper custom-colour support without the CDN scan overhead.

4. **Campaign admin** — a minimal Administrate or custom CRUD so non-developers can create campaigns and upload cover images (Active Storage + S3) without touching seeds.

5. **Tests** — model unit tests for `total_raised_cents`, `progress_bar_segments`, and `displayed_name`; system tests (Capybara) for the donation modal flow and tab switching.

6. **i18n via `rails-i18n`** — replace the hand-rolled `config/locales/he.yml` with the full gem so `number_to_currency`, form error messages, and `time_ago_in_words` all localise automatically.

7. **Accessible markup** — `aria-modal`, `aria-labelledby`, focus trap inside the donation modal, and keyboard-navigable preset grid.

8. **Rate-limit donation submissions** — Rack::Attack rule keyed on IP to prevent abuse before a real payment gate is in place.
