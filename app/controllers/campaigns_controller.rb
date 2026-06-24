class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.all.order(:id)
  end

  def show
    @campaign = Campaign.find(params[:id])
    @active_tab = params.fetch(:tab, "story")
    @active_tab = "story" unless %w[story updates donors].include?(@active_tab)
    @donation ||= @campaign.donations.build(frequency: "monthly")
  end
end
