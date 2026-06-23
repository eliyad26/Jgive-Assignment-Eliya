class DonationsController < ApplicationController
  def create
    @campaign = Campaign.find(params[:campaign_id])

    amount_cents = (params.dig(:donation, :amount_ils).to_f * 100).round
    dp = donation_params

    @donation = @campaign.donations.build(
      amount_cents:       amount_cents,
      currency:           "ILS",
      frequency:          dp[:frequency].presence || "one_time",
      display_preference: dp[:display_preference].presence || "full_name",
      donor_name:         dp[:donor_name].to_s.strip,
      dedication:         dp[:dedication].to_s.strip.presence,
      status:             "pending"
    )

    if @donation.save
      redirect_to campaign_path(@campaign, tab: "donors"),
                  notice: "תודה! תרומתך נרשמה בהצלחה ותאושר בקרוב."
    else
      redirect_to campaign_path(@campaign),
                  alert: @donation.errors.full_messages.join(" | ")
    end
  end

  private

  def donation_params
    params.require(:donation).permit(:frequency, :display_preference, :donor_name, :dedication)
  end
end
