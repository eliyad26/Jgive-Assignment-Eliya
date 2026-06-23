require_relative "boot"

require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module JgiveAssignmentEliya
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "Jerusalem"
    config.i18n.default_locale = :he
    config.i18n.available_locales = %i[he en]
  end
end
