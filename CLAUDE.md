# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project

JGive home assignment — a fundraising campaign clone built in Ruby on Rails.
Scope: a campaign show page (tabs: Story / Updates / Donors), a donation form that
creates pending donations and updates campaign progress, and seed data. No payment
processing — that is described in the README only.

Time budget: 4–6 hours per the brief. Optimize for clear scope decisions over
breadth of features.

## Visual reference

UI should mirror this page as closely as practical:
https://www.jgive.com/new/he/ils/donation-targets/159183

Key visual elements to match: Hebrew RTL layout, dual-zone progress bar
(paid vs. pending segments, with overflow styling if raised exceeds goal),
tab navigation, donation form sidebar with preset amount grid, Heebo or
similar Hebrew font.

"Exactly like" is aspirational — aim for clearly-inspired-by, same palette,
same layout structure. Do not burn budget on pixel-perfect CSS.

## Working conventions

1. **Update README.md continuously.** After every task, ensure a developer
   with zero context can:
   - Set up the app locally (Ruby version, bundle install, db:create/migrate/seed, rails s)
   - Understand the architecture (models, controllers, view structure, Stimulus controllers)
   - Reproduce any non-obvious decisions

2. **Maintain a "Decisions & Trade-offs" section in README.md.** Append to it as you work.
   Note anything where you chose scope-out over scope-in. The final entry must be
   a "Wiring in a Real Payment Provider" subsection describing the pending → paid
   flow with a real provider (Stripe Checkout + webhook, or Israeli equivalents like
   Tranzila / Meshulam / PayPlus).

3. **One commit per task.** Descriptive commit messages. Do not squash.

4. **No payment integration in code.** Donations are created with status: pending
   and stay there. The README explains how a real provider would be wired in.

5. **Scope discipline.** If a task tempts you toward auth, admin UI, email receipts,
   i18n machinery, or anything not in the brief — stop and ask before adding it.

6. **BEFORE EVERY COMMIT — present the work for review and wait for approval.**
   - Confirm the dev server is running (`bin/rails s`)
   - Tell me the exact URL(s) to visit to see the change
   - Walk me through what to look at and what to interact with
     (e.g., "visit /campaigns/1, scroll to the donation form, select ₪250,
     click submit, observe the flash message and the updated pending segment
     of the progress bar")
   - List files changed with a one-line summary of each
   - Then STOP. Do not run `git commit` until I reply with approval
     ("commit it" / "looks good" / "ship it" / similar)
   - If I give feedback, iterate and re-present. Repeat until approved.
   - For tasks with no visual output (models, migrations, seeds), demonstrate
     via `bin/rails console`: print `Campaign.first.attributes`, a few sample
     donations, `Campaign.first.progress_percentage`, etc., so I can verify
     the data shape.

## Stack

- **Ruby** 3.2.11 / **Rails** 7.1
- **Database** SQLite3 (development & test)
- **JavaScript** — Stimulus + Importmap (no Node, no Webpack) — _to be added_
- **CSS** — Tailwind CSS via CDN (dev); swap to `tailwindcss-rails` gem before production
- **Font** — Heebo via Google Fonts CDN (`app/views/layouts/application.html.erb`)

## Commands

```bash
# Setup (one-time — requires internet access from your terminal)
gem install rails --no-document && bundle install
ruby bin/rails db:create db:migrate db:seed

# Daily
ruby bin/rails server          # http://localhost:3000
ruby bin/rails console

# Re-seed (truncates existing data)
ruby bin/rails db:seed

# Run tests
ruby bin/rails test
```

> On Windows, prefix with `ruby` or use `bundle exec rails`.

## Architecture

- **`Campaign`** — the central model; holds both the main goal and optional bonus goal
  (nil = single-goal campaign). Instance methods compute progress without capping at 100%.
- **`Donation`** — belongs to Campaign; status enum (pending/paid/failed); pending donations
  count toward the progress bar immediately.
- **`CampaignsController#show`** — renders the campaign page with tabs (Story / Updates / Donors).
- **`DonationsController#create`** — creates a pending donation and redirects back with flash.
- Stimulus controllers (to be added): `tabs` for tab switching, `progress-bar` for the
  dual-zone bar animation.