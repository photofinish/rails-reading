# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application




# begin
# require 'config/boot'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'  # Set up gems listed in the Gemfile.
# require 'rails/all'
require 'rails'
%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end
# require 'config/application'
Bundler.require(*Rails.groups)    # Require the gems listed in Gemfile
module RailsReadingDemo
  class Application < Rails::Application      # 触发 inherited hook
  end
end
# require 'config/environment'
Rails.application.initialize!
# config.cu
run Rails.application
# end
