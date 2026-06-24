Donation.delete_all
Campaign.delete_all
# Reset auto-increment so IDs restart at 1 on each seed run (SQLite and PostgreSQL)
case ActiveRecord::Base.connection.adapter_name
when /SQLite/i
  ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name IN ('campaigns','donations')")
when /PostgreSQL/i
  ActiveRecord::Base.connection.execute("SELECT setval('campaigns_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('donations_id_seq', 1, false)")
end

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
  { donor_name: "יוסף כהן",      amount_cents: 10_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: 'לזכר אבי ז"ל יעקב כהן', created_at: 30.days.ago },
  { donor_name: "מירה לוי",       amount_cents: 15_000_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil,                                              created_at: 25.days.ago },
  { donor_name: "שלמה גולדברג",   amount_cents:  5_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: "בברכת בריאות לכל המשפחה",                       created_at: 22.days.ago },
  { donor_name: "אבי ישראלי",     amount_cents: 20_000_000, status: "paid",    frequency: "one_time", display_preference: "anonymous",  dedication: nil,                                              created_at: 18.days.ago },
  { donor_name: "רחל אברהם",      amount_cents:  7_500_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: nil,                                              created_at: 15.days.ago },
  { donor_name: "דוד שפירא",      amount_cents:  8_000_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil,                                              created_at: 12.days.ago },
  { donor_name: "חנה גרינברג",    amount_cents:  2_500_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: 'לזכר אמי ז"ל חיה גרינברג',                      created_at: 9.days.ago },
  { donor_name: "משה פרידמן",     amount_cents: 12_000_000, status: "paid",    frequency: "monthly",  display_preference: "anonymous",  dedication: nil,                                              created_at: 7.days.ago },
  { donor_name: "שרה ויס",        amount_cents:  6_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                                              created_at: 4.days.ago },
  { donor_name: "אריה סילבר",     amount_cents:  3_500_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil,                                              created_at: 2.days.ago },
  { donor_name: "נעמי כץ",        amount_cents:  4_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: "לבריאות ורפואה שלמה לנכדיי",                    created_at: 1.day.ago },
  { donor_name: "יהודה בנימין",   amount_cents:  9_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                                              created_at: 6.hours.ago },
  { donor_name: "תמר הלפרין",     amount_cents:  2_500_000, status: "pending", frequency: "one_time", display_preference: "full_name",  dedication: nil,                                              created_at: 3.hours.ago },
  { donor_name: "אלי ספיר",       amount_cents:  1_563_000, status: "pending", frequency: "monthly",  display_preference: "first_name", dedication: nil,                                              created_at: 40.minutes.ago },
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
  { donor_name: "רוני ברנשטיין",  amount_cents: 12_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil, created_at: 14.days.ago },
  { donor_name: "אסתר מנדלסון",   amount_cents:  8_000_000, status: "paid",    frequency: "one_time", display_preference: "anonymous",  dedication: nil, created_at: 10.days.ago },
  { donor_name: "נחום אזריאל",    amount_cents: 15_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil, created_at: 7.days.ago },
  { donor_name: "שמחה רוזנברג",   amount_cents:  6_000_000, status: "paid",    frequency: "monthly",  display_preference: "first_name", dedication: nil, created_at: 4.days.ago },
  { donor_name: "פנינה אלקלעי",   amount_cents:  7_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil, created_at: 1.day.ago },
  { donor_name: "גדעון פרץ",      amount_cents:    750_000, status: "pending", frequency: "one_time", display_preference: "full_name",  dedication: nil, created_at: 2.hours.ago },
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
  { donor_name: "אביגדור הורביץ",  amount_cents: 25_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 60.days.ago },
  { donor_name: "שושנה פישר",      amount_cents: 10_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 55.days.ago },
  { donor_name: "מרדכי יצחק",      amount_cents:  8_000_000, frequency: "one_time", display_preference: "anonymous",  created_at: 50.days.ago },
  { donor_name: "ציפורה נתן",       amount_cents: 20_000_000, frequency: "one_time", display_preference: "first_name", created_at: 45.days.ago },
  { donor_name: "ברוך שטרן",        amount_cents:  5_000_000, frequency: "monthly",  display_preference: "full_name",  created_at: 40.days.ago },
  { donor_name: "פנחס קצמן",        amount_cents: 12_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 36.days.ago },
  { donor_name: "לאה ריינהארד",     amount_cents:  7_500_000, frequency: "one_time", display_preference: "anonymous",  created_at: 32.days.ago },
  { donor_name: "גדליה שמש",        amount_cents:  6_000_000, frequency: "one_time", display_preference: "first_name", created_at: 28.days.ago },
  { donor_name: "מינה צוקרמן",      amount_cents:  4_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 24.days.ago },
  { donor_name: "עקיבא הרמן",       amount_cents:  9_000_000, frequency: "monthly",  display_preference: "full_name",  created_at: 21.days.ago },
  { donor_name: "בתיה מרגלית",      amount_cents:  3_000_000, frequency: "one_time", display_preference: "anonymous",  created_at: 18.days.ago },
  { donor_name: "חיים כנפו",        amount_cents: 11_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 15.days.ago },
  { donor_name: "רבקה אוחנה",       amount_cents:  4_500_000, frequency: "one_time", display_preference: "first_name", created_at: 13.days.ago },
  { donor_name: "שמואל דגן",        amount_cents:  2_500_000, frequency: "one_time", display_preference: "full_name",  created_at: 11.days.ago },
  { donor_name: "שלומית עמית",      amount_cents:  7_000_000, frequency: "monthly",  display_preference: "full_name",  created_at: 9.days.ago },
  { donor_name: "מאיר ברקוביץ'",    amount_cents:  3_500_000, frequency: "one_time", display_preference: "anonymous",  created_at: 7.days.ago },
  { donor_name: "יונה אלון",        amount_cents:  8_500_000, frequency: "one_time", display_preference: "full_name",  created_at: 5.days.ago },
  { donor_name: "אורה שחר",         amount_cents:  5_500_000, frequency: "one_time", display_preference: "first_name", created_at: 4.days.ago },
  { donor_name: "נסים אביב",        amount_cents:  6_500_000, frequency: "one_time", display_preference: "full_name",  created_at: 3.days.ago },
  { donor_name: "חגית ראם",         amount_cents:  9_500_000, frequency: "monthly",  display_preference: "full_name",  created_at: 2.days.ago },
  { donor_name: "אלכסנדר דינר",     amount_cents:  5_000_000, frequency: "one_time", display_preference: "anonymous",  created_at: 1.day.ago },
  { donor_name: "זהבה גנות",        amount_cents:  2_000_000, frequency: "one_time", display_preference: "full_name",  created_at: 4.hours.ago },
].each { |attrs| campaign_c.donations.create!(currency: "ILS", status: "paid", dedication: nil, **attrs) }

# Verify totals:
# 250+100+80+200+50+120+75+60+40+90+30+110+45+25+70+35+85+55+65+95+50+20 = 1,750K ILS → 175%

# ── Campaign D: הגן הכתום — dual-goal, ~53% of main goal ──────────────────
campaign_d = Campaign.create!(
  title:                   "לזכר בני משפחת ביבס",
  slogan:                  "הצטרפו עכשיו והיו ממקימי ׳הגן הכתום׳",
  story:                   <<~STORY,
    על הפרויקט
    הצטרפו עכשיו והיו ממקימי ׳הגן הכתום׳

    לזכר שירי, אריאל וכפיר ביבס,
    ולזכר כל ילדי ה-7 באוקטובר.
    אחרי שנתיים וחצי של כאב, טלטלה והתמודדות,
    מגיע מיזם שמביא בשורה חדשה לישראל -
    מקום של חיים, ריפוי ותקווה.
    אנחנו יוצאים לדרך עם הקמת הגן הכתום -
    מרחב ראשון מסוגו בישראל שמחבר זיכרון, טבע ילדים וריפוי.
    על פני 20 דונם יוקם מרחב חי של טבע, מים, משחק, משפחה וריפוי - פתוח לכולם.
    מקום שבו ילדים ירוצו וישחקו,
    משפחות יתכנסו יחד,
    ואנשים יוכלו לעצור לרגע, לנשום ולהתחבר מחדש.
    מקום שיכלול גם מרחב מכבד לזכר כל ילדי השבעה באוקטובר -
    כדי לזכור דרך החיים, האור והאהבה.
    למען כל ילדי ישראל 🧡
    למען התיקון של כולנו.

    מה יחכה לנו בגן הכתום?
    הגן הכתום מוקם במגדל העמק, סמוך לגני הילדים "אריאל" ו"כפיר" הנבנים בימים אלה.

    🌿 מתחם גינון טיפולי-קהילתי
    מרחב ריפוי דרך הטבע והאדמה עבור הלומי קרב, בני הגיל השלישי, אנשים עם צרכים מיוחדים, נוער בסיכון וקהילות הזקוקות לצמיחה מחדש.

    🍊 בוסתני פרי ומטעים
    הליכה בין עצי פרי, ריחות וצמחייה, בהשראת הפירות ששירי ואריאל אהבו.

    💧 הנחל האקולוגי
    נחל זורם המלווה את המבקרים לאורך הגן, עם גשרי עץ קטנים, מים חיים וחוויית הליכה מרגיעה.

    🌱 מרחב זיכרון לכל ילדי השבעה באוקטובר
    פינה מכבדת ומלאת אור, לזכר הילדים שנלקחו מעולמנו.

    🧡 האומגה הכתומה ומתקני המשחק
    כי צחוק של ילדים הוא התשובה הכי חזקה לכאב.

    🌟 קיר המשאלות
    מקום שבו כל ילד וילדה בישראל יוכלו להשאיר משאלה, תפילה, תקווה או חלום.

    👨‍👩‍👧 מרחבי פיקניק משפחתיים
    פינות מפגש ירוקות ומזמינות, ליצירת זיכרונות חדשים תחת כיפת השמיים.

    🎭 אמפיתיאטרון, כיתות חוץ ומרחבי תרבות
    מקום למפגשים, הופעות, פעילות חינוכית וקהילתית.

    📚 ספריית חוץ ומרחב השראה
    פינות ישיבה מוצלות עם ספרי ילדים, שולחנות יצירה ומקום לדמיון לצמוח.

    זהו פרויקט לאומי של אהבה, אחריות ותקווה.
    ההזדמנות שלנו להשאיר חותם לדורות.

    עיריית מגדל העמק העניקה את הקרקע והתחייבה לתחזוקה שוטפת.
    התוכניות מוכנות. עכשיו אנחנו צריכים אתכם.

    ״ראינו את התכניות של הגן, ופשוט התחלנו לבכות״
    כשעופרי ביבס ראתה לראשונה את התוכנית של הגן, היא לא הצליחה לעצור את הדמעות.

    עמותת וְנָטַעְתָּ, מובילת הפרויקט, היא תנועה לאומית-סביבתית לריפוי החברה הישראלית דרך הטבע וחיבור לאדמה.
    העמותה זוכת Israel Earth Prize לשנת 2023.
    פרויקט ׳הגן הכתום׳ מתקיים בשיתוף פעולה מלא עם עיריית מגדל העמק ומשפחת ביבס.
  STORY
  cover_image_url:         "/images/orange-garden.png",
  video_url:               "https://youtu.be/4Z_xXXR3ddU",
  goal_amount_cents:       200_000_000,   # ₪2,000,000
  bonus_goal_amount_cents: 300_000_000,   # ₪3,000,000
  currency:                "ILS"
)

# Donations totalling ~₪1,064,883 → 53% of ₪2,000,000 goal
[
  { donor_name: "עופרי ביבס",       amount_cents:  5_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: "לזכר שירי, אריאל וכפיר",      created_at: 60.days.ago },
  { donor_name: "דורית כהן",        amount_cents: 10_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at: 45.days.ago },
  { donor_name: "משה לוי",          amount_cents:  8_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: nil,                            created_at: 40.days.ago },
  { donor_name: "רחל ישראלי",       amount_cents: 15_000_000, status: "paid",    frequency: "one_time", display_preference: "first_name", dedication: nil,                            created_at: 35.days.ago },
  { donor_name: "אנונימי",          amount_cents: 20_000_000, status: "paid",    frequency: "one_time", display_preference: "anonymous",  dedication: nil,                            created_at: 30.days.ago },
  { donor_name: "יוסי גולן",        amount_cents:  5_000_000, status: "paid",    frequency: "monthly",  display_preference: "full_name",  dedication: "לזכר ילדי ה-7 באוקטובר",     created_at: 25.days.ago },
  { donor_name: "שרה מזרחי",        amount_cents:  3_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at: 20.days.ago },
  { donor_name: "אבי שפירא",        amount_cents: 12_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at: 15.days.ago },
  { donor_name: "נועה ברון",        amount_cents:  7_000_000, status: "paid",    frequency: "monthly",  display_preference: "first_name", dedication: nil,                            created_at: 10.days.ago },
  { donor_name: "גיל אלון",         amount_cents:  4_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at:  7.days.ago },
  { donor_name: "מירב רוזן",        amount_cents:  6_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at:  5.days.ago },
  { donor_name: "דן שחר",           amount_cents:  9_000_000, status: "paid",    frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at:  3.days.ago },
  { donor_name: "תמי פרץ",          amount_cents:  2_500_000, status: "pending", frequency: "one_time", display_preference: "full_name",  dedication: nil,                            created_at:  2.hours.ago },
  { donor_name: "יעל דוד",          amount_cents:  1_388_300, status: "pending", frequency: "monthly",  display_preference: "first_name", dedication: nil,                            created_at:  1.hour.ago  },
].each { |attrs| campaign_d.donations.create!(currency: "ILS", **attrs) }

# Verify: 5+10+8+15+20+5+3+12+7+4+6+9 = 104M paid + 2.5M+1.388M pending = 107,888,300 agorot ≈ 53.9%

puts "Seeded #{Campaign.count} campaigns, #{Donation.count} donations."
puts "Campaign A progress: #{campaign_a.main_progress_percentage}%  (expect ~53)"
puts "Campaign B has_bonus_goal?: #{campaign_b.has_bonus_goal?}  (expect false)"
puts "Campaign C progress: #{campaign_c.main_progress_percentage}%  (expect ~175)"
puts "Campaign D (Orange Garden) progress: #{campaign_d.main_progress_percentage}%"
