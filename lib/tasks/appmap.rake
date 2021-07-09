# frozen_string_literal: true

lambda do
  def simplify(file)
    file.index(Dir.pwd) == 0 ? file[Dir.pwd.length+1..-1] : file
  end

  namespace :appmap do
    AppMap::Swagger::RakeTasks.define_tasks

    def run_minitest(test_files)
      test_files = test_files.map(&method(:simplify)).uniq

      # DISABLE_SPRING because it's likely to not have APPMAP=true
      succeeded = system({ 'APPMAP' => 'true', 'DISABLE_SPRING' => '1' }, "bundle exec rails test #{test_files.map(&:shellescape).join(' ')}")
      exit 1 unless succeeded
    end

    test_runner = ->(test_files) { run_minitest(test_files) }
    AppMap::Depends::RakeTasks.define_tasks test_runner: test_runner

    task :architecture do
      test_files = File.read('ARCHITECTURE.md').scan(/\[[^\(]+\(([^\]]+)\)\]\(.*\.appmap\.json\)/).flatten
      test_files = test_files.map(&method(:simplify)).uniq

      succeeded = system({ 'APPMAP' => 'true', 'DISABLE_SPRING' => '1' }, "bundle exec rails test #{test_files.map(&:shellescape).join(' ')}")
      exit 1 unless succeeded
    end
  end

  desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
  task :appmap => [ :'appmap:depends:update' ]
end.call if %w[test development].member?(Rails.env)
