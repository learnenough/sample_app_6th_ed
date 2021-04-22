namespace :db do
  task :diagram do
    system('bundle exec erd')
  end

  Rake::Task['db:migrate'].enhance do
    Rake::Task['db:diagram'].execute
  end
end
