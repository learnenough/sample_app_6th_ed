# frozen_string_literal: true

lambda do
  namespace :appmap do
    AppMap::Swagger::RakeTasks.define_tasks

    def run_minitest(test_files)
      simplify = ->(f) { f.index(Dir.pwd) == 0 ? f[Dir.pwd.length+1..-1] : f }
      test_files = test_files.map(&simplify).uniq

      # DISABLE_SPRING because it's likely to not have APPMAP=true
      succeeded = system({ 'APPMAP' => 'true', 'DISABLE_SPRING' => '1' }, "bundle exec rails test #{test_files.map(&:shellescape).join(' ')}")
      exit 1 unless succeeded
    end

    test_runner = ->(test_files) { run_minitest(test_files) }
    AppMap::Depends::RakeTasks.define_tasks test_runner: test_runner
  end

  desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
  task :appmap => [ :'appmap:depends:update' ]
end.call if %w[test development].member?(Rails.env)
