class CampaignsController < ApplicationController
  def show
    @campaign = Campaign.find(params[:id])
    @active_tab = params.fetch(:tab, "story")
    @active_tab = "story" unless %w[story updates donors].include?(@active_tab)
    # @donation may already be set by DonationsController on a failed save (re-render path)
    @donation ||= @campaign.donations.build(frequency: "monthly")
  end
end
