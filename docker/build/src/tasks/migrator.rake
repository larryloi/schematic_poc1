# frozen-string-literal: true

require_relative '../lib/schematic/migrator'

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |_, args|
    version = args[:version].to_i if args[:version]
    Schematic::Migrator.new.migrate(version: version)
  end

  desc "Remove migrations"
  task :clean do |_, args|
    Schematic::Migrator.new.clean
  end

  desc "Remove migrations and re-run migrations"
  task :reset do |_, args|
    Schematic::Migrator.new.clean
  end

  desc "Apply last n migrations"
  task :apply, [:steps] do |_, args|
    Schematic::Migrator.new.apply(steps: args.steps || 1)
  end

  desc "Rollback last n migrations"
  task :rollback, [:steps] do |_, args|
    Schematic::Migrator.new.rollback(steps: args.steps || 1)
  end

  desc "Redo last n migrations"
  task :redo, [:steps] do |_, args|
    Schematic::Migrator.new.redo(steps: args.steps || 1)
  end

  desc "Create a migration file with a timestamp and name"
  task :create_migration, :name do |_, args|
    unless args.name
      abort 'Aborted! Migration name is missing.'
      exit 1
    end

    Schematic::Migrator.new.create_migration(args.name)
  end

  desc "Show applied schema migrations"
  task :applied_migrations do |_, args|
    Schematic::Migrator.new.show_applied_migrations
  end

  desc "Show a given applied schema migration"
  task :applied_migration, :steps do |_, args|
    steps = (args.steps || -1).to_i
    Schematic::Migrator.new.show_applied_migration(steps)
  end

  desc "Show schema migrations to apply"
  task :migrations_to_apply do |_, args|
    Schematic::Migrator.new.show_migrations_to_apply
  end

  desc "Show a given schema migration to apply"
  task :migration_to_apply, :steps do |_, args|
    steps = (args.steps || 0).to_i
    Schematic::Migrator.new.show_migration_to_apply(steps)
  end
end
