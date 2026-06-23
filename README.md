# Jgive Assignment — Eliya Duek

A fundraising campaign clone inspired by [JGive](https://www.jgive.com/new/he/ils/donation-targets/159183).
Built with Ruby on Rails 7.1, SQLite3, Hebrew RTL.

## Setup

**Prerequisites:** Ruby 3.2.x, Bundler (`gem install bundler`)

```bash
# 1. Install gems (requires internet)
gem install rails --no-document
bundle install

# 2. Create and migrate the database
ruby bin/rails db:create db:migrate

# 3. Seed the three demo campaigns
ruby bin/rails db:seed

# 4. Start the development server
ruby bin/rails server
```

Visit http://localhost:3000

> **Windows note:** prefix all `bin/rails` commands with `ruby` (e.g. `ruby bin/rails …`),
> or use `bundle exec rails …` after `bundle install`.

## Architecture

### Models

| Model      | Table       | Key columns |
|------------|-------------|-------------|
| `Campaign` | `campaigns` | `title`, `goal_amount_cents`, `bonus_goal_amount_cents` (nil = single-goal), `currency` |
| `Donation` | `donations` | `campaign_id`, `amount_cents`, `status` (pending/paid/failed), `frequency` (one_time/monthly), `display_preference`, `dedication` |

**Campaign instance methods:**

| Method | Returns |
|--------|---------|
| `total_raised_cents` | sum of pending + paid donations |
| `donor_count` | count of non-failed donations |
| `main_progress_percentage` | integer %, not capped (can exceed 100) |
| `has_bonus_goal?` | true when `bonus_goal_amount_cents` is present |
| `display_donations` | non-failed donations ordered by `created_at desc` |

**Donation instance methods:**

| Method | Returns |
|--------|---------|
| `displayed_name` | respects `display_preference`: full name / first name only / "תורם אנונימי" |

### Seed data

Three campaigns covering all progress-bar states:

| Campaign | Goal | Bonus goal | Raised | Progress |
|----------|------|-----------|--------|----------|
| קרן מלגות לסטודנטים מצטיינים | ₪2,000,000 | ₪5,000,000 | ₪1,065,630 | ~53% |
| בנק המזון ירושלים | ₪750,000 | — | ₪487,500 | 65% |
| רכישת ציוד רפואי לבית חולים שיבא | ₪1,000,000 | ₪3,000,000 | ₪1,750,000 | 175% |

Re-seed at any time: `ruby bin/rails db:seed` (truncates first).

### Controllers & views

| Route | Controller#Action | Notes |
|-------|------------------|-------|
| `GET /` | `campaigns#show` (id: 1) | Root redirects to campaign 1 |
| `GET /campaigns/:id` | `campaigns#show` | Campaign show page |
| `POST /campaigns/:id/donations` | `donations#create` | Donation form submit (next task) |

**View structure:**
- `app/views/layouts/application.html.erb` — RTL layout (`lang="he" dir="rtl"`), Heebo font (Google Fonts), Tailwind CDN
- `app/views/campaigns/show.html.erb` — campaign header strip + placeholder tab/form sections

**Helpers (`app/helpers/application_helper.rb`):**

| Helper | Purpose |
|--------|---------|
| `format_ils(cents)` | Formats integer cents as `₪1,065,630` |
| `youtube_embed_url(url)` | Converts YouTube watch URL → embed URL |
| `progress_bar_segments(campaign)` | Returns `{teal:, orange:, goal_marker:}` percentages for the dual-zone bar |

### Progress bar component

The dual-zone bar (`app/views/campaigns/show.html.erb`, `progress_bar_segments` helper) works as follows:

- **Domain** = `bonus_goal_amount_cents` if a bonus goal exists; otherwise `max(goal, raised)`
- **Teal segment** = progress from 0 → main goal (capped at the goal marker)
- **Orange segment** = overflow from main goal → raised amount (only appears when raised > goal)
- **Goal-line divider** = a white hairline at the goal marker position (only shown for dual-goal campaigns)

Three visual states across the seed campaigns:
| Campaign | Bar appearance |
|----------|---------------|
| A (53%, dual-goal) | 21% teal (of 5M domain), no orange |
| B (65%, single-goal) | 65% teal, no overflow |
| C (175%, dual-goal) | 33% teal + 25% orange, divider at 33% |

## Decisions & Trade-offs

### Task 1: Data layer

- **Amounts stored as integer cents** — avoids floating-point errors; all display formatting
  done in helpers/views.
- **String-valued enums** (`status`, `frequency`, `display_preference`) — readable in the
  SQLite database without a lookup table.
- **`story` is a plain `text` column** — Action Text / Trix editor not included yet to stay
  within 4–6 h scope. Can be added later; the column would be replaced with an Action Text
  attachment.
- **No authentication, no admin UI** — out of scope per brief.
- **No payment integration in code** — donations are created as `pending` and stay there.

### Task 2: Campaign header strip

- **Tailwind via CDN** — `tailwindcss-rails` gem was scoped out to avoid native-extension
  build failures on the dev machine (MSYS2 keyring issue). The CDN script is flagged with
  a comment; swap to the gem before production.
- **Heebo font via Google Fonts CDN** — same reasoning; works for demo without asset pipeline.
- **Progress bar is pure HTML+CSS** — no Stimulus controller needed for a static display.
  When the donation form is wired up, the bar will re-render server-side on each page load.
  A Stimulus controller for smooth animation would be a polish pass.
- **RTL achieved via `dir="rtl"` on `<html>`** — Tailwind's RTL utilities (e.g. `rtl:flex-row-reverse`)
  are not needed; native browser RTL flips flex order automatically.
- **Media fallback order**: `video_url` (YouTube embed) → `cover_image_url` → teal placeholder.

### Wiring in a Real Payment Provider

When a real payment is collected, a provider webhook moves the donation from `pending` → `paid`.
Here is how that flow would be wired for **Stripe Checkout** (and equivalents for Israeli
providers Tranzila / Meshulam / PayPlus work the same way):

1. **Create a Checkout Session** (`DonationsController#create`)
   - Persist the donation with `status: :pending`.
   - Call `Stripe::Checkout::Session.create(...)`, passing the `donation.id` as
     `metadata[:donation_id]` and a `success_url` / `cancel_url`.
   - Redirect the donor to `session.url`.

2. **Receive the webhook** (new `WebhooksController`)
   - Stripe (or provider) POSTs `checkout.session.completed` to `/webhooks/stripe`.
   - Verify the signature with `Stripe::Webhook.construct_event(payload, sig, secret)`.
   - Read `metadata[:donation_id]`, find the record, and call
     `donation.update!(status: :paid)`.
   - Return HTTP 200.

3. **Handle the success redirect** (`CampaignsController#show` or a `DonationsController#success`)
   - The donor is returned to `success_url` (e.g. `/campaigns/1?donation=123`).
   - Because the webhook may arrive before the redirect, check `donation.reload.status`
     — show a "payment confirmed" or "payment processing" message accordingly.

4. **Israeli equivalents**
   - **Tranzila / Meshulam / PayPlus** provide hosted payment pages and callback URLs
     (rather than webhooks). The pattern is: redirect to provider → provider redirects
     back to a callback URL with a transaction token → verify the token via provider API
     → update `status: :paid`.

5. **Failed / expired payments**
   - Handle `checkout.session.expired` (or provider timeout callback) by setting
     `status: :failed`. The progress bar already excludes failed donations from totals.
