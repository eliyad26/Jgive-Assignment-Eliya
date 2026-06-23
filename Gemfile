source "https://rubygems.org"
ruby "3.2.11"

gem "rails", "~> 8.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# Pin to bundled Ruby default gems to avoid native-extension recompilation on Windows
gem "psych", "~> 5.0.0"

group :development, :test do
  gem "sqlite3", ">= 2.1"
  gem "debug", platforms: %i[mri windows]
end

group :production do
  gem "pg"
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end
