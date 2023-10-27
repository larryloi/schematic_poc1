# frozen-string-literal: true

module Schematic
  class Migrator
    def create_migration(name)
      migration_template = <<~MIGRATION
        # frozen_string_literal: true

        Sequel.migration do
          change do
          end
        end
      MIGRATION
  
      file_name = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{name}.rb"
      FileUtils.mkdir_p(migration_dir)

      migration_file = File.join(migration_dir, file_name)
  
      File.open(migration_file, 'w') do |file|
        file.write(migration_template)
      end
      puts "New migration is created: #{migration_file}"
    end
  end
end
