module ApplicationHelper
  # Format integer cents as Israeli shekel string: ₪1,065,630
  def format_ils(cents)
    "₪#{number_with_delimiter(cents / 100, delimiter: ',')}"
  end

  # Same but wrapped in a <span data-cents="N"> for the JS currency toggle
  def format_ils_tag(cents)
    content_tag(:span, format_ils(cents), data: { cents: cents })
  end

  # Convert YouTube watch URL → embed URL
  def youtube_embed_url(video_url)
    return nil if video_url.blank?
    match = video_url.match(%r{(?:v=|youtu\.be/)([^&\n?#]+)})
    "https://www.youtube.com/embed/#{match[1]}" if match
  end

  # Progress bar segments.
  # Dual-goal: bar domain = bonus_goal. Purple fills from left (raised/bonus).
  #            Green fills from right ((bonus-goal)/bonus). Heart at tip of purple.
  # Single-goal: green fills from left (raised/goal). Heart at tip of green.
  def progress_bar_segments(campaign)
    raised = campaign.total_raised_cents.to_f
    goal   = campaign.goal_amount_cents.to_f
    return { type: :single, fill: 0.0 } if goal.zero?

    if campaign.has_bonus_goal?
      bonus = campaign.bonus_goal_amount_cents.to_f
      return { type: :dual, purple: 0.0, green_right: 0.0, heart_left: 0.0 } if bonus.zero?

      purple_pct  = [(raised / bonus * 100), 100.0].min.round(2)
      green_right = [((bonus - goal) / bonus * 100), 100.0].min.round(2)
      heart_left  = (100.0 - green_right).round(2)
      { type: :dual, purple: purple_pct, green_right: green_right, heart_left: heart_left }
    else
      fill_pct = [(raised / goal * 100), 100.0].min.round(2)
      { type: :single, fill: fill_pct }
    end
  end
end
