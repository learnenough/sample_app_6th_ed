# frozen_string_literal: true

if defined?(AppMap)
  require 'appmap/middleware/remote_recording'

  Rails.application.config.middleware.insert_after \
    Rails::Rack::Logger,
    AppMap::Middleware::RemoteRecording
end
