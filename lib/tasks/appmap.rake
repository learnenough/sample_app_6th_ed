# frozen_string_literal: true

lambda do
  namespace :appmap do
    AppMap::Swagger::RakeTasks.define_tasks
    AppMap::Depends::RakeTasks.define_tasks
    
    task :architecture do
      simplify = ->(f) { f.index(Dir.pwd) == 0 ? f[Dir.pwd.length+1..-1] : f }
    
      test_files = File.read('ARCHITECTURE.md').scan(/\[[^\(]+\(([^\]]+)\)\]\(.*\.appmap\.json\)/).flatten
      test_files = test_files.map(&simplify).uniq

      succeeded = system({ 'APPMAP' => 'true', 'DISABLE_SPRING' => '1' }, "bundle exec rails test #{test_files.map(&:shellescape).join(' ')}")
      exit 1 unless succeeded
    end
  end

  desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
  task :appmap => [ :'appmap:depends:update' ]
end.call if %w[test development].member?(Rails.env) && defined?(AppMap)
