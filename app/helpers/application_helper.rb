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

  # Dual-zone progress bar widths.
  # The "domain" is bonus_goal (if present) or max(goal, raised) so the bar
  # always fits in 100% of the container width.
  #
  # Returns { teal:, orange:, goal_marker: } as percentages of container width.
  #   teal        — fill from 0 to the goal marker (primary zone)
  #   orange      — fill from goal marker to raised amount (overflow zone)
  #   goal_marker — where to draw the goal divider line
  def progress_bar_segments(campaign)
    raised = campaign.total_raised_cents.to_f
    goal   = campaign.goal_amount_cents.to_f
    return { teal: 0.0, orange: 0.0, goal_marker: 100.0 } if goal.zero?

    domain = if campaign.has_bonus_goal?
               campaign.bonus_goal_amount_cents.to_f
             elsif raised > goal
               raised
             else
               goal
             end
    return { teal: 0.0, orange: 0.0, goal_marker: 100.0 } if domain.zero?

    fill_pct        = [(raised / domain * 100), 100.0].min
    goal_marker_pct = [(goal / domain * 100), 100.0].min
    teal_pct        = [fill_pct, goal_marker_pct].min
    orange_pct      = [fill_pct - goal_marker_pct, 0.0].max

    { teal: teal_pct.round(2), orange: orange_pct.round(2), goal_marker: goal_marker_pct.round(2) }
  end
end
