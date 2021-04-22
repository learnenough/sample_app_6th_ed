namespace :appmap do
  if %w[test development].member?(Rails.env)
    # In a Rails app, add a dependency on the :environment task.
    AppMap::Swagger::RakeTask.new(:swagger, [] => [ :environment ]).tap do |task|
      task.project_name = 'Rails Sample App API'
      task.project_version = 'v6'
    end
    AppMap::Swagger::RakeDiffTask.new(:'swagger:diff', [ :base, :swagger_file ]).tap do |task|
      task.base = 'remotes/origin/following-users'
    end
  end
end
