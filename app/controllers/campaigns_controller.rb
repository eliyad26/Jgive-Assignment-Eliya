class CampaignsController < ApplicationController
  def show
    @campaign = Campaign.find(params[:id])
    @active_tab = params.fetch(:tab, "story")
    @active_tab = "story" unless %w[story updates donors].include?(@active_tab)
  end
end
