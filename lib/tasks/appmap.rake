# frozen_string_literal: true

namespace :appmap do
  BASE_BRANCH = 'origin/appmap-e2e'

  def swagger_tasks
    AppMap::Swagger::RakeTask.new.tap do |task|
      task.project_name = 'Rails Sample App API'
      task.project_version = 'v6'
    end
    AppMap::Swagger::RakeDiffTask.new(:'swagger:diff', [ :base, :swagger_file ]).tap do |task|
      task.base = 'remotes/origin/following-users'
    end
    
    task :'swagger:uptodate' do
      swagger_diff = `git diff swagger/openapi_stable.yaml`
      if swagger_diff != ''
        warn 'swagger/openapi_stable.yaml has been modified:'
        warn swagger_diff
        warn 'Bring it up to date with the command rake appmap:swagger'
        exit 1
      end
    end
  end

  def run_minitest(test_files)
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
      exit 0
    end

    Process.wait pid
    exit $?.exitstatus unless $?.exitstatus == 0
  end

  def depends_tasks
    require 'appmap_depends'

    namespace :depends do
      task :modified do
        @appmap_modified_files = AppMap::Depends.modified
        AppMap::Depends.report_list 'Out of date', @appmap_modified_files
      end

      task :diff do
        @appmap_modified_files = AppMap::Depends.diff(base: BASE_BRANCH)
        AppMap::Depends.report_list 'Out of date', @appmap_modified_files
      end

      task :test_file_report do
        @appmap_test_file_report = AppMap::Depends.inspect_test_files
        @appmap_test_file_report.report
      end

      task :update_appmaps do
        @appmap_test_file_report.clean_appmaps

        @appmap_modified_files += @appmap_test_file_report.modified_files

        if @appmap_modified_files.blank?
          warn 'AppMaps are up to date'
          next
        end

        start_time = Time.current
        AppMap::Depends.run_tests(@appmap_modified_files) do |test_files|
          run_minitest(test_files)
        end
        removed = AppMap::Depends.remove_out_of_date_appmaps(start_time)
        warn "Removed out of date AppMaps: #{removed.join(' ')}" unless removed.empty?
      end
    end

    desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
    task :modified => [ :'depends:modified', :'depends:test_file_report', :'depends:update_appmaps', :swagger ]

    desc 'Bring AppMaps up to date with file modifications relative to the base branch'
    # TODO: Add :swagger, :'swagger:uptodate'
    task :diff, [ :base ] => [ :'depends:diff', :'depends:update_appmaps' ]
  end

  if %w[test development].member?(Rails.env)
    swagger_tasks
    depends_tasks
  end
end

if %w[test development].member?(Rails.env)
  desc 'Bring AppMaps up to date with local file modifications, and updated derived data such as Swagger files'
  task :appmap => [ :'appmap:modified' ]
end
