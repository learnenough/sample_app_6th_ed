# Puma configuration file.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count
port        ENV.fetch("HTTP_PORT") { 8080 }
environment ENV.fetch("RAILS_ENV") { ENV['RACK_ENV'] || "development" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
if ENV.fetch("RAILS_ENV") { ENV['RACK_ENV'] || "development" } == 'production'
  ssl_bind ENV.fetch("INTERFACE") { '127.0.0.1' }, ENV.fetch("HTTPS_PORT") { 8443 }, {
    cert: ENV['SSL_CRT'],
    key: ENV['SSL_KEY'],
    verify_mode: 'none',
  }
end
preload_app!
plugin :tmp_restart
