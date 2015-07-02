# Activerecord migrations
require 'active_record_migrations'
ActiveRecordMigrations.configure do |c|
  c.database_configuration = ActiveRecord::Base.configurations
  c.db_dir = 'config/db'
  c.environment = ENV['RACK_ENV']
  c.migrations_paths = ['config/db/migrations']
end
ActiveRecordMigrations.load_tasks
