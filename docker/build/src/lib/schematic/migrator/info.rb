# frozen-string-literal: true

module Schematic
  class Migrator
    def show_applied_migrations
      applied_migrations.each do |migration|
        version, file = migration.split('_', 2)
        puts "-- #{version} : #{File.basename(file, '.rb')}"
      end
    end

    def show_applied_migration(step)
      migration = applied_migration(step)
      if migration.empty?
        puts "Aborted! Migration step #{step} is not found; probably out of range"
      else
        puts "-- #{migration[:version]} : #{migration[:name]}"
      end
    end

    def show_migrations_to_apply
      migrations_to_apply.each do |migration|
        version, file = migration.split('_', 2)
        puts "-- #{version} : #{File.basename(file, '.rb')}"
      end
    end

    def show_migration_to_apply(step)
      migration = migration_to_apply(step)
      if migration.empty?
        puts "Aborted! Migration step #{step} is not found; probably out of range"
      else
        puts "-- #{migration[:version]} : #{migration[:name]}"
      end
    end

    protected

    def applied_migrations
      Sequel::Migrator.migrator_class(migration_dir).new(
        db_connection, 
        migration_dir,
        {}
      ).applied_migrations
    end

    def applied_migration(step)
      migration = applied_migrations[step]
      if migration.nil?
        {}
      else
        version, file = migration.split('_', 2)
        { version: version.to_i, name: File.basename(file, '.rb') }
      end
    end

    def migrations_to_apply
      migrator = Sequel::Migrator.migrator_class(migration_dir).new(
        db_connection, 
        migration_dir,
        {}
      )
      migrator.files.map do |file|
        File.basename(file)
      end - migrator.applied_migrations
    end

    def migration_to_apply(step)
      migration = migrations_to_apply[step]
      if migration.nil?
        {}
      else
        version, file = migration.split('_', 2)
        { version: version.to_i, name: File.basename(file, '.rb') }
      end
    end
  end
end
