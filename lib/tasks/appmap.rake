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
    $LOAD_PATH << 'test'
    test_files.each do |test_file|
      load test_file
    end
    $ARGV.replace []
    Minitest.autorun
  end

  def depends_tasks
    require 'appmap_depends'
    require 'shellwords'

    AppMap::Depends::Task::DiffTask.new.tap do |diff_task|
      diff_task.base = BASE_BRANCH
    end.define
    AppMap::Depends::Task::ModifiedTask.new.define

    task :'test:setup' do
      raise "Task requires RAILS_ENV=test, got #{Rails.env}" unless Rails.env.test?
      AppMap::Depends.verbose(Rake.verbose == true)      
    end

    task :minitest_depends do
      test_files = File.read('tmp/appmap_depends_modified.txt').split("\n")
      run_minitest(test_files) unless test_files.empty?
    end

    desc 'Run tests that depend on a locally modified file'
    task :'test:modified' => [ :'test:setup', :'depends:modified', :'minitest_depends' ]

    desc 'Run tests that depend on a file which is modified relative to the base branch'
    task :'test:diff', [ :base ] => [ :'test:setup', :'depends:diff', :'minitest_depends' ]
  end
  
  if %w[test development].member?(Rails.env)
    swagger_tasks
    depends_tasks  
  end
end
