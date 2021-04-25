# frozen_string_literal: true

if defined?(AppMap) && ENV['APPMAP_REMOTE'] == 'true'
  require 'appmap/middleware/remote_recording'

  Rails.application.config.middleware.insert_after \
    Rails::Rack::Logger,
    AppMap::Middleware::RemoteRecording
end
