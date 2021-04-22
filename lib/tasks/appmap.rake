namespace :appmap do
  def swagger_tasks
    # In a Rails app, add a dependency on the :environment task.
    AppMap::Swagger::RakeTask.new(:swagger, [] => [ :environment ]).tap do |task|
      task.project_name = 'Rails Sample App API'
      task.project_version = 'v6'
    end
    AppMap::Swagger::RakeDiffTask.new(:'swagger:diff', [ :base, :swagger_file ]).tap do |task|
      task.base = 'remotes/origin/following-users'
    end
  end

  BASE_BRANCH = 'origin/appmap-e2e'

  def run_minitest(test_files)
    if test_files.blank?
      warn 'Tests are up to date'
    else
      warn 'Out of date files:'
      warn test_files.join(' ')
      $LOAD_PATH << 'test'
      test_files.each do |test_file|
        load test_file
      end
      $ARGV.replace []
      Minitest.autorun
    end
  end

  def depends_tasks
    require 'appmap_depends'
    require 'shellwords'

    task :'test:setup' do
      ENV['RAILS_ENV'] = 'test'
      AppMap::Depends.verbose(Rake.verbose == true)      
    end

    task :'test:modified' => :'test:setup' do
      depends = AppMap::Depends::AppMapJSDepends.new
      test_files = depends.depends
      run_minitest test_files
    end

    desc 'Run tests that are modified relative to the base branch'
    task :'test:diff', [ :base ] => :'test:setup' do |t, args|
      base = args[:base] || BASE_BRANCH
      modified_files = AppMap::Depends::GitDiff.new(base: base).modified_files
      if Rake.verbose == true
        warn "Files modified relative to #{base}: #{modified_files.join(' ')}"
      end
      test_files = AppMap::Depends::AppMapJSDepends.new.depends(modified_files)
      run_minitest test_files
    end
  end
  
  if %w[test development].member?(Rails.env)
    swagger_tasks
    depends_tasks  
  end
end
