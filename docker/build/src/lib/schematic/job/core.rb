require "pathname"
require_relative "../cipher"

module Schematic
  class Job
    attr_reader :options
    attr_reader :default_options

    def initialize(opts = {})
      @options = opts
      yield @options if block_given?
      on_init
      set_default_options
      set_default_values
    end

    def default_job_dir
      File.join("jobs", ENV['DB_NAME'])
    end

    def job_dir
      @job_dir ||= init_job_dir
    end

    def work_dir
      @work_dir ||= init_work_dir
    end

    def default_work_dir = Dir.pwd

    def job_env_dir
      File.join(@work_dir, "env/jobs")
    end

    protected

    def set_default_options
      @default_options ||= {
        work: default_work_dir,
        job_dir: default_job_dir
      }
    end

    def set_default_values
      @options = default_options.merge(@options)
    end

    def init_job_dir
      dir = Pathname.new(options[:job_dir] || default_job_dir)
      dir.absolute? ? dir.to_s : File.join(work_dir, dir.to_s)
    end

    def init_work_dir
      (options[:work_dir] || default_work_dir)
    end


    def on_init
      msdb_url = ENV['DATABASE_URL']
      msdb_url = msdb_url.gsub("#{ENV['DB_NAME']}", "msdb")

      @options[:db_type] = ENV['DB_TYPE']
      @options[:db_adapter] = ENV['DB_ADAPTER']
      @options[:db_host] = ENV['DB_HOST']
      @options[:db_name] = 'msdb'
      @options[:db_user] = ENV['DB_USER']
      @options[:db_password] =
        ENV['DB_PASSWORD_ENCRYPTED'].nil? ||
        ENV['DB_PASSWORD_ENCRYPTED'].empty? ?
          ENV['DB_PASSWORD'] :
          decrypt_db_password(ENV['DB_PASSWORD_ENCRYPTED'])
      @options[:database_url] = msdb_url
    end

    def decrypt_db_password(encrypted_password)
      Schematic::Cipher.new.decrypt(encrypted_password)
    end

    def db_connection
      @options[:db_connection] ||=
        Sequel.connect(
          options[:database_url],
          user: options[:db_user],
          password: options[:db_password]
        ).tap do |db|
          if options[:db_type] == 'mssql'
            db.extension :identifier_mangling
            db.identifier_input_method = nil
            db.identifier_output_method = nil
          end
        end
    end
  end
end