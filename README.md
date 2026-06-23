# JGive Assignment — Eliya Duek

A fundraising campaign clone inspired by [JGive](https://www.jgive.com/new/he/ils/donation-targets/159183).
Built with Ruby on Rails 8.1, SQLite3, Hebrew RTL layout, Tailwind CSS via CDN, and Heebo font.

---

## 1. Setup

**Prerequisites:** Ruby 3.2.x, Bundler (`gem install bundler`)

```bash
# 1. Install gems (requires internet access)
gem install rails --no-document
bundle install

# 2. Create and migrate the database
ruby bin/rails db:create db:migrate

# 3. Seed the three demo campaigns
ruby bin/rails db:seed

# 4. Start the development server
ruby bin/rails server
# → http://localhost:3000
```

> **Windows note:** prefix all `bin/rails` commands with `ruby`
> (e.g. `ruby bin/rails …`), or use `bundle exec rails …` after `bundle install`.

To **re-seed** (truncates all existing campaigns and donations):

```bash
ruby bin/rails db:seed
```

---

## 2. The Three Seed Campaigns

Three campaigns are seeded to demonstrate every progress-bar state:

| # | Campaign | Goal | Bonus goal | Raised | State |
|---|----------|------|-----------|--------|-------|
| 1 | קרן מלגות לסטודנטים מצטיינים | ₪2,000,000 | ₪5,000,000 | ₪1,065,630 | ~53% — single teal bar (below goal) |
| 2 | בנק המזון ירושלים | ₪750,000 | — (single-goal) | ₪487,500 | 65% — single-goal teal bar |
| 3 | רכישת ציוד רפואי לבית חולים שיבא | ₪1,000,000 | ₪3,000,000 | ₪1,750,000 | 175% — teal + orange overflow |

Visit `/campaigns/1`, `/campaigns/2`, `/campaigns/3` (or set the root to any of them in `config/routes.rb`).

---

## 3. Architecture

### Models

| Model | Table | Key columns |
|-------|-------|-------------|
| `Campaign` | `campaigns` | `title`, `description`, `story`, `goal_amount_cents`, `bonus_goal_amount_cents` (nil = single-goal), `currency`, `cover_image_url`, `video_url` |
| `Donation` | `donations` | `campaign_id`, `amount_cents`, `status` (pending/paid/failed), `frequency` (one_time/monthly), `display_preference` (full_name/first_name/anonymous), `donor_name`, `dedication` |

**Campaign computed methods:**

| Method | Returns |
|--------|---------|
| `total_raised_cents` | Sum of `pending` + `paid` donations (failed excluded) |
| `donor_count` | Count of non-failed donations |
| `main_progress_percentage` | Integer %, uncapped (can exceed 100 for overflow) |
| `has_bonus_goal?` | `true` when `bonus_goal_amount_cents` is present |
| `display_donations` | Non-failed donations, newest first |

**Donation computed methods:**

| Method | Returns |
|--------|---------|
| `displayed_name` | Respects `display_preference`: full name / first token / "תורם/ת אנונימי/ת" |

### Controllers

| Route | Controller#Action | Notes |
|-------|------------------|-------|
| `GET /` | `campaigns#show` (id: 1) | Root defaults to campaign 1 |
| `GET /campaigns/:id` | `campaigns#show` | Campaign show page |
| `POST /campaigns/:id/donations` | `donations#create` | Creates a `pending` donation; redirects to Donors tab on success |

**`CampaignsController#show`**  
Sets `@campaign`, `@active_tab` (whitelist-guarded, defaults to `"story"`), and `@donation ||= build(frequency: "monthly")`. The `||=` is intentional — on a failed donation save, `DonationsController#create` re-renders `campaigns/show` with `@donation` already set (carrying validation errors), so `CampaignsController#show` must not overwrite it.

**`DonationsController#create`**  
Converts the form's `donation[amount_ils]` (shekels) to cents: `(amount_ils.to_f * 100).round`. On success, redirects to `?tab=donors#donors-list`. On failure, re-renders `campaigns/show` at HTTP 422 with `@donation` bearing `.errors`.

### Views

| File | Purpose |
|------|---------|
| `app/views/layouts/application.html.erb` | `lang="he" dir="rtl"` HTML root, Heebo + Tailwind CDN, sticky site header, flash banner with auto-dismiss |
| `app/views/campaigns/show.html.erb` | Campaign header strip, dual-zone progress bar, two-column layout (form sidebar + tabs) |
| `app/views/donations/_form.html.erb` | Donation form card: frequency toggle, preset grid, name/dedication fields, client-side validation (inline IIFE JS) |
| `app/views/shared/_empty_state.html.erb` | Reusable empty-state (accepts `icon:`, `title:`, `subtitle:` locals; icons: `:box`, `:bell`, `:users`) |

### Helpers (`app/helpers/application_helper.rb`)

| Helper | Purpose |
|--------|---------|
| `format_ils(cents)` | Formats integer cents → `₪1,065,630` |
| `youtube_embed_url(url)` | Converts YouTube watch URL → `/embed/ID` |
| `progress_bar_segments(campaign)` | Returns `{ teal:, orange:, goal_marker: }` percentages for the dual-zone bar |

### Stimulus / JavaScript

No Stimulus controllers are installed. All client-side interactivity is a single inline IIFE inside `donations/_form.html.erb` (~60 lines):
- Preset amount buttons: clicking one sets the hidden input and applies active styling
- Frequency toggle: flips white-card style between monthly / one-time
- Client-side validation: red ring + inline message on missing name or zero amount, `e.preventDefault()` before server round-trip

Tab switching (Story / Updates / Donors) is server-rendered via `?tab=` query param — no JS needed.

---

## 4. Progress Bar

The dual-zone bar is rendered in `app/views/campaigns/show.html.erb` using the `progress_bar_segments` helper.

**Domain:** `bonus_goal_amount_cents` (if present); otherwise `max(goal, raised)`.

| Segment | Color | Covers |
|---------|-------|--------|
| Teal | `#0da89e` | 0 → main goal (capped at goal marker) |
| Orange | `#ff6b35` | Main goal → raised amount (only when raised > goal) |
| White hairline divider | `rgba(255,255,255,0.7)` | At the goal-marker position (dual-goal campaigns only) |

The bar container uses `dir="ltr"` so CSS `left:`/`width:` fill left-to-right regardless of the page-level `dir="rtl"`.

**Three visual states across seed campaigns:**

| Campaign | Bar |
|----------|-----|
| A — 53%, dual-goal | ~21% teal (of 5M domain), no orange segment |
| B — 65%, single-goal | 65% teal, no overflow |
| C — 175%, dual-goal | ~33% teal + ~25% orange, white divider at 33% |

---

## 5. Visual Reference

Target: [https://www.jgive.com/new/he/ils/donation-targets/159183](https://www.jgive.com/new/he/ils/donation-targets/159183)

**Matched elements:**
- Hebrew RTL layout (`lang="he" dir="rtl"`)
- Heebo font (Google Fonts CDN), weights 300–900
- Teal brand color `#0da89e` (header text, progress bar, tab underline, active preset ring)
- Purple CTA buttons `#d426ff` (hover `#b800e0`) — "תרום עכשיו" in the header and the form submit
- Dual-zone progress bar: teal (main progress) + orange overflow when raised exceeds goal
- Tab bar: Story / Updates / Donors with teal active underline
- Sticky donation form sidebar (desktop right; mobile full-width above tabs)
- 3×2 preset amount grid
- Frequency toggle (monthly / one-time) with white-card active state
- Donor list with masking (first name only / anonymous), pending badge, Hebrew relative timestamps

**Intentional divergences (scope):**
- No user authentication / login wall
- No admin panel or campaign editing UI
- No email receipts
- No Action Text / rich-text story editor (story is plain text)
- Tailwind via CDN (not gem) — swap to `tailwindcss-rails` before production

---

## 6. Payment Provider Wiring

Donations are created with `status: :pending` and stay there in this implementation. Here is how a real provider would be wired in:

### Stripe Checkout (recommended for international)

1. **Create a Checkout Session** (`DonationsController#create`)
   - Persist the donation with `status: :pending`.
   - Call `Stripe::Checkout::Session.create(...)`, passing `donation.id` as `metadata[:donation_id]`.
   - Redirect the donor to `session.url`.

2. **Receive the webhook** (new `WebhooksController`)
   - Stripe POSTs `checkout.session.completed` to `/webhooks/stripe`.
   - Verify the signature: `Stripe::Webhook.construct_event(payload, sig_header, secret)`.
   - Find the donation via `metadata[:donation_id]`, call `donation.update!(status: :paid)`.
   - Return HTTP 200.

3. **Handle the success redirect**
   - The donor returns to `success_url` (e.g. `/campaigns/1?donation=123`).
   - Because the webhook may arrive before the redirect, reload the record and show
     "payment confirmed" or "payment processing" accordingly.

4. **Failed / expired payments**
   - Handle `checkout.session.expired` by setting `status: :failed`.
   - The progress bar already excludes failed donations from `total_raised_cents`.

### Israeli equivalents (Tranzila / Meshulam / PayPlus)

These providers use a **hosted payment page + callback URL** pattern instead of webhooks:

1. Redirect donor to the provider's hosted page with a signed request.
2. Provider redirects back to your callback URL with a transaction token.
3. Verify the token via the provider's API.
4. On success, call `donation.update!(status: :paid)`.

The model change is identical (`pending → paid`); only the HTTP flow differs.

---

## 7. Decisions & Trade-offs

### Task 1 — Data layer

- **Integer cents for amounts** — avoids floating-point rounding errors. All display formatting (`₪1,065,630`) is done in `format_ils` helper / views.
- **String-valued enums** (`status`, `frequency`, `display_preference`) — readable in the SQLite file without a lookup table; easier to inspect in `rails console`.
- **`story` as plain `text` column** — Action Text / Trix editor scoped out; the column can later be replaced with an Action Text attachment without a model migration.
- **No authentication, no admin UI** — out of scope per brief.

### Task 2 — Campaign header strip

- **Tailwind via CDN** — `tailwindcss-rails` gem requires MSYS2 native build (failed on the dev machine). The CDN `<script>` tag is flagged with a comment; swap to the gem before production.
- **Heebo via Google Fonts CDN** — same reasoning as Tailwind.
- **Progress bar in pure HTML+CSS** — no Stimulus controller; the bar re-renders server-side on each page load, which is sufficient given that donations are submitted via a full form POST.
- **RTL via `dir="rtl"` on `<html>`** — browser native RTL flips flex order automatically; no `rtl:` Tailwind variants or `order` overrides needed.

### Task 3 — Donors tab

- **Pending donations are visible in the list** — shown with an amber "ממתין לאישור" badge. Consistent with `total_raised_cents` already counting pending donations toward the progress bar.
- **Anonymous avatar is a silhouette SVG** — avoids showing a letter initial that could hint at the donor's identity.
- **Hebrew `time_ago_in_words` without `rails-i18n` gem** — `config/locales/he.yml` provides only the `datetime.distance_in_words` keys needed. Avoids a network-dependent `bundle install`.
- **Server-rendered tabs** — `?tab=<name>` query param; no Stimulus required. Acceptable for a read-heavy page within 4–6 h scope.

### Task 4 — Donation form

- **Amount stored as cents, form submits in shekels** — form field is `donation[amount_ils]`; controller converts: `(amount_ils.to_f * 100).round`. Human-readable form, integer model.
- **Monthly pre-selected** — JGive emphasises recurring giving; matches the reference UI.
- **Inline IIFE JS instead of Stimulus** — avoids adding `importmap-rails` + `stimulus-rails` gems (both require network access). The JS is progressive-enhancement: HTML5 `required` and server-side validation remain the authority.
- **`novalidate` on the form** — disables inconsistent native browser validation UI in favour of the custom red-ring styling applied by the JS.

### Task 5 — Controller flow

- **`@donation ||= build(...)` in `CampaignsController#show`** — the `||=` prevents overwriting the error-bearing `@donation` set by `DonationsController#create` on a failed save, enabling pre-fill and inline errors.
- **Redirect to `?tab=donors#donors-list` on success** — the donor sees their new pending entry immediately in the list, anchored so the browser scrolls past the sidebar.
- **Progress bar auto-updates** — `total_raised_cents` already sums pending + paid, so the header strip reflects the new donation the moment the page re-renders. No extra wiring.

---

## 8. Seed Data Details

Seed file: `db/seeds.rb`

SQLite sequences are reset at the start of each seed run so IDs remain stable across re-seeds:

```ruby
ActiveRecord::Base.connection.execute(
  "DELETE FROM sqlite_sequence WHERE name IN ('campaigns','donations')"
)
```

| Campaign | Donations | Mix |
|----------|-----------|-----|
| A — קרן מלגות | 14 | 12 paid + 2 pending; spread over past 90 days |
| B — בנק המזון | 6 | 5 paid + 1 pending; spread over past 60 days |
| C — ציוד רפואי | 22 | All paid; spread over past 120 days |

`created_at` timestamps are spread across the look-back window so Hebrew relative timestamps
(`time_ago_in_words`) display varied values ("לפני 3 ימים", "לפני חודש", etc.) across the Donors tab.

Display preferences in seed data cover all three options (full name / first name / anonymous)
so the masking logic can be verified immediately after seeding.
