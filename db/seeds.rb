Donation.delete_all
Campaign.delete_all

# ── Campaign A: Scholarship fund, dual-goal, ~53% of main goal ─────────────
campaign_a = Campaign.create!(
  title:                  "קרן מלגות לסטודנטים מצטיינים",
  slogan:                 "כי עתיד ישראל מתחיל בחינוך",
  story:                  <<~STORY,
    קרן המלגות לסטודנטים מצטיינים הוקמה בשנת 2009 מתוך מטרה אחת פשוטה: לוודא שהגבול הכלכלי לא יהיה חסם בפני הכשרון הישראלי.

    מדי שנה אנו מעניקים מלגות לעשרות סטודנטים מצטיינים מרקעים כלכליים מאתגרים, המאפשרות להם להתמקד בלימודים ולממש את הפוטנציאל שלהם.

    כל תרומה — קטנה כגדולה — הופכת להזדמנות לשנות חיים.
  STORY
  cover_image_url:        nil,
  video_url:              "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  goal_amount_cents:      200_000_000,   # ₪2,000,000
  bonus_goal_amount_cents: 500_000_000,  # ₪5,000,000
  currency:               "ILS"
)

# 12 paid + 2 pending = ₪1,065,630 total → 53% of goal
[
  { donor_name: "יוסף כהן",      amount_cents: 10_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: 'לזכר אבי ז"ל יעקב כהן' },
  { donor_name: "מירה לוי",       amount_cents: 15_000_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil },
  { donor_name: "שלמה גולדברג",   amount_cents:  5_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: "בברכת בריאות לכל המשפחה" },
  { donor_name: "אבי ישראלי",     amount_cents: 20_000_000, status: "paid",    frequency: "one_time", display_preference: "anonymous",  dedication: nil },
  { donor_name: "רחל אברהם",      amount_cents:  7_500_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: nil },
  { donor_name: "דוד שפירא",      amount_cents:  8_000_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil },
  { donor_name: "חנה גרינברג",    amount_cents:  2_500_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: 'לזכר אמי ז"ל חיה גרינברג' },
  { donor_name: "משה פרידמן",     amount_cents: 12_000_000, status: "paid",    frequency: "monthly",  display_preference: "anonymous",  dedication: nil },
  { donor_name: "שרה ויס",        amount_cents:  6_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "אריה סילבר",     amount_cents:  3_500_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil },
  { donor_name: "נעמי כץ",        amount_cents:  4_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: "לבריאות ורפואה שלמה לנכדיי" },
  { donor_name: "יהודה בנימין",   amount_cents:  9_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "תמר הלפרין",     amount_cents:  2_500_000, status: "pending", frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "אלי ספיר",       amount_cents:  1_563_000, status: "pending", frequency: "monthly",  display_preference: "first_name", dedication: nil },
].each { |attrs| campaign_a.donations.create!(currency: "ILS", **attrs) }

# Verify: 10+15+5+20+7.5+8+2.5+12+6+3.5+4+9 = 102.5M paid, +2.5M+1.563M pending = 106,563,000 agorot = 53.28%

# ── Campaign B: Food bank, single-goal, ~65% of goal ──────────────────────
campaign_b = Campaign.create!(
  title:                  "בנק המזון ירושלים",
  slogan:                 "כי אף אחד לא צריך ללכת רעב",
  story:                  <<~STORY,
    בנק המזון ירושלים מחלק מדי חודש מזון לאלפי משפחות ויחידים בעיר ובסביבתה. אנו עובדים עם מסעדות, רשתות שיווק ויצרנים כדי להציל מזון ראוי לאכילה ולהעביר אותו לאנשים שזקוקים לו.

    עם תרומתכם נוכל להרחיב את פעילותנו ולהגיע לעוד משפחות המתמודדות עם חוסר ביטחון תזונתי.
  STORY
  cover_image_url:        nil,
  video_url:              nil,
  goal_amount_cents:      75_000_000,    # ₪750,000
  bonus_goal_amount_cents: nil,
  currency:               "ILS"
)

# 5 paid + 1 pending = ₪487,500 → 65% of goal
[
  { donor_name: "רוני ברנשטיין",  amount_cents: 12_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "אסתר מנדלסון",   amount_cents:  8_000_000, status: "paid",    frequency: "one_time", display_preference: "anonymous",  dedication: nil },
  { donor_name: "נחום אזריאל",    amount_cents: 15_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "שמחה רוזנברג",   amount_cents:  6_000_000, status: "paid",    frequency: "monthly",  display_preference: "first_name", dedication: nil },
  { donor_name: "פנינה אלקלעי",   amount_cents:  7_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil },
  { donor_name: "גדעון פרץ",      amount_cents:    750_000, status: "pending", frequency: "one_time", display_preference: "full_name",  dedication: nil },
].each { |attrs| campaign_b.donations.create!(currency: "ILS", **attrs) }

# Verify: 12+8+15+6+7 = 48M paid, +0.75M pending = 48,750,000 agorot = 65%

# ── Campaign C: Medical equipment, dual-goal, ~175% of goal ───────────────
campaign_c = Campaign.create!(
  title:                  "רכישת ציוד רפואי לבית חולים שיבא",
  slogan:                 "מציידים את הרפואה הישראלית לעתיד",
  story:                  <<~STORY,
    בית חולים שיבא — המרכז הרפואי הגדול בישראל ובמזרח התיכון — מטפל מדי שנה במאות אלפי מטופלים מרחבי הארץ ומהעולם.

    כחלק ממהפכת הרפואה הדיגיטלית, אנו נדרשים לרכוש ציוד הדמיה מתקדם שיאפשר אבחון מדויק, טיפול מהיר יותר והצלת חיים.

    כל שקל שתתרמו הולך ישירות לציוד רפואי — לא לדמי ניהול.
  STORY
  cover_image_url:        nil,
  video_url:              nil,
  goal_amount_cents:      100_000_000,   # ₪1,000,000
  bonus_goal_amount_cents: 300_000_000,  # ₪3,000,000
  currency:               "ILS"
)

# 22 paid, all = ₪1,750,000 → 175% of main goal
[
  { donor_name: "אביגדור הורביץ",  amount_cents: 25_000_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "שושנה פישר",      amount_cents: 10_000_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "מרדכי יצחק",      amount_cents:  8_000_000, frequency: "one_time", display_preference: "anonymous"  },
  { donor_name: "ציפורה נתן",       amount_cents: 20_000_000, frequency: "one_time", display_preference: "first_name" },
  { donor_name: "ברוך שטרן",        amount_cents:  5_000_000, frequency: "monthly",  display_preference: "full_name"  },
  { donor_name: "פנחס קצמן",        amount_cents: 12_000_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "לאה ריינהארד",     amount_cents:  7_500_000, frequency: "one_time", display_preference: "anonymous"  },
  { donor_name: "גדליה שמש",        amount_cents:  6_000_000, frequency: "one_time", display_preference: "first_name" },
  { donor_name: "מינה צוקרמן",      amount_cents:  4_000_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "עקיבא הרמן",       amount_cents:  9_000_000, frequency: "monthly",  display_preference: "full_name"  },
  { donor_name: "בתיה מרגלית",      amount_cents:  3_000_000, frequency: "one_time", display_preference: "anonymous"  },
  { donor_name: "חיים כנפו",        amount_cents: 11_000_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "רבקה אוחנה",       amount_cents:  4_500_000, frequency: "one_time", display_preference: "first_name" },
  { donor_name: "שמואל דגן",        amount_cents:  2_500_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "שלומית עמית",      amount_cents:  7_000_000, frequency: "monthly",  display_preference: "full_name"  },
  { donor_name: "מאיר ברקוביץ'",    amount_cents:  3_500_000, frequency: "one_time", display_preference: "anonymous"  },
  { donor_name: "יונה אלון",        amount_cents:  8_500_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "אורה שחר",         amount_cents:  5_500_000, frequency: "one_time", display_preference: "first_name" },
  { donor_name: "נסים אביב",        amount_cents:  6_500_000, frequency: "one_time", display_preference: "full_name"  },
  { donor_name: "חגית ראם",         amount_cents:  9_500_000, frequency: "monthly",  display_preference: "full_name"  },
  { donor_name: "אלכסנדר דינר",     amount_cents:  5_000_000, frequency: "one_time", display_preference: "anonymous"  },
  { donor_name: "זהבה גנות",        amount_cents:  2_000_000, frequency: "one_time", display_preference: "full_name"  },
].each { |attrs| campaign_c.donations.create!(currency: "ILS", status: "paid", dedication: nil, **attrs) }

# Verify totals:
# 250+100+80+200+50+120+75+60+40+90+30+110+45+25+70+35+85+55+65+95+50+20 = 1,750K ILS → 175%

puts "Seeded #{Campaign.count} campaigns, #{Donation.count} donations."
puts "Campaign A progress: #{campaign_a.main_progress_percentage}%  (expect ~53)"
puts "Campaign B has_bonus_goal?: #{campaign_b.has_bonus_goal?}  (expect false)"
puts "Campaign C progress: #{campaign_c.main_progress_percentage}%  (expect ~175)"
