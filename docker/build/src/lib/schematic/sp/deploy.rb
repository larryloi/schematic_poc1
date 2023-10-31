require 'pathname'

module Schematic
  class Sp

    def create(spname)
      sp_template = <<~TEMPLATE
        CREATE PROCEDURE [dbo].[sp_name]
        AS
        BEGIN
          SELECT * FROM sys.objects o JOIN sys.schemas s ON o.schema_id = s.schema_id
          WHERE type = 'P' AND o.name = 'sp_name' AND s.name = 'dbo'
        END
        TEMPLATE

      file_name = "#{spname}.sql"
      FileUtils.mkdir_p(sp_dir)

      sp_file = File.join(sp_dir, file_name)

      File.open(sp_file, 'w') do |file|
        file.write(sp_template)
      end
      puts "New Stored procedure template is created: #{sp_file}"
    end


    def deploy
      dir = Pathname.new(sp_dir)

      Dir.glob(dir.join('*.sql')) do |file|
        sql = File.read(file)

        # Split the SQL script into separate commands at each 'GO' statement
        commands = sql.split('GO')
        puts "\n  >> Executing script from #{file}\n"

        commands.each do |command|
          unless command.strip.empty?
            # Extract schema and procedure name from the command
            match_data = command.match(/CREATE PROCEDURE \[(?<schema>.+)\]\.\[(?<procedure>.+)\]/)
            next unless match_data

            schema_name = match_data[:schema]
            procedure_name = match_data[:procedure]

            db_name = @options[:db_name]
            # Check if the procedure exists
            check_sql = "SELECT * FROM sys.objects o JOIN sys.schemas s ON o.schema_id = s.schema_id WHERE type = 'P' AND o.name = '#{procedure_name}' AND s.name = '#{schema_name}'"
            result = db_connection.fetch(check_sql).all

            if result.nil? || result.empty?
              puts "  >> Create new stored procedure."
              db_connection.run(command)
            else
              alter_command = command.gsub('CREATE PROCEDURE', 'ALTER PROCEDURE')
              puts "  >> Update existing stored procedure."
              db_connection.run(alter_command)
            end


          end
        end
      end
    end
  end
end