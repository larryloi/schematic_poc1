# frozen-string-literal: true

module Schematic
  class Migrator
    def migrate(version: nil)
      run_migrator(target: version.nil? ? nil : Integer(version))
      puts "Completed migration up of #{options[:db_name]}"
    end

    def clean
      run_migrator(target: 0)
      puts "Completed migration clean of #{options[:db_name]}"
    end

    def reset
      clean
      migrate
      puts "Completed migration reset of #{options[:db_name]}"
    end

    def apply(steps: 1)
      steps = Integer(steps)
      up(steps)
      puts "Completed migration up of #{options[:db_name]} for #{steps} step(s)"
    end

    def rollback(steps: 1)
      steps = Integer(steps)
      down(steps)
      puts "Completed migration down of #{options[:db_name]} for #{steps} step(s)"
    end

    def redo(steps: 1)
      steps = Integer(steps)
      down(steps)
      up(steps)
      puts "Completed migration redo of #{options[:db_name]} for #{steps} step(s)"
    end

    protected

    def up(steps)
      run_migrator(target: migration_to_apply(steps - 1)[:version])
    end

    def down(steps)
      run_migrator(target: applied_migration(- steps - 1)[:version] || 0)
    end

    def run_migrator(**opts)
      Sequel::Migrator.run(
        db_connection,
        migration_dir,
        table: migration_table, **opts
      )
    end
  end
end
