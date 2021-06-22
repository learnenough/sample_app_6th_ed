# frozen_string_literal: true

lambda do
  namespace :appmap do
    AppMap::Swagger::RakeTasks.define_tasks

    def run_minitest(test_files)
      raise "APPMAP must be 'true', but it's '#{ENV['APPMAP']}'" unless ENV['APPMAP'] == 'true'
      raise "RAILS_ENV must be 'test', but it's '#{Rails.env}'" unless ENV['RAILS_ENV'] == 'test'
      pid = fork
      if pid.nil?
        $LOAD_PATH << 'test'
        simplify = ->(f) { f.index(Dir.pwd) == 0 ? f[Dir.pwd.length+1..-1] : f }
        test_files.map(&simplify).uniq.each do |test_file|
          load test_file
        end
        $ARGV.replace []
        Minitest.autorun
        # Minitest.autorun kicks in when the process exits; and it replaces the exit code.
        exit 0
      end

      Process.wait pid
      exit $?.exitstatus unless $?.exitstatus == 0
    end

    test_runner = ->(test_files) { run_minitest(test_files) }
    AppMap::Depends::RakeTasks.define_tasks test_runner: test_runner
  end

  desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
  task :appmap => [ :'appmap:depends:update' ]
end.call if %w[test development].member?(Rails.env)
