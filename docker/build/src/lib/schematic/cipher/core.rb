# frozen-string-literal: true

require "pathname"

module Schematic
  class Cipher
    attr_reader :options
    attr_reader :default_options

    def initialize(opts = {})
      @options = opts
      yield @options if block_given?
      on_init
      set_default_options
      set_default_values
    end

    def issuer
      @issuer ||= init_issuer
    end

    def default_issuer = 'schematic'

    def algorithm
      @algorithm ||= init_algorithm
    end

    def default_algorithm = 'RS256'

    def key_length
      @key_length ||= init_key_length
    end
  
    def default_key_length = 4096

    def keys_dir
      @keys_dir ||= init_keys_dir
    end

    def default_keys_dir = '.cipher'

    def work_dir
      @work_dir ||= init_work_dir
    end

    def default_work_dir = Dir.pwd

    def private_key_file = File.join(keys_dir, "#{issuer}.priv")
    def public_key_file = File.join(keys_dir, "#{issuer}.pub")
  
    protected

    def set_default_options
      @default_options ||= {
        key_length: default_key_length,
        algorithm: default_algorithm
      }
    end

    def set_default_values
      @options = default_options.merge(@options)
    end

    def init_issuer
      @options[:issuer] || default_issuer
    end

    def init_algorithm
      @options[:algorithm] || default_algorithm
    end

    def init_key_length
      @options[:key_length] || default_key_length
    end

    def init_keys_dir
      dir = Pathname.new(options[:keys_dir] || default_keys_dir)
      dir.absolute? ? dir.to_s : File.join(work_dir, dir.to_s)
    end

    def init_work_dir
      (options[:work_dir] || default_work_dir)
    end

    def on_init
      @options[:algorithm] = ENV['SCHEMATIC_CIPHER_ALGORITHM']
      @options[:key_length] = ENV['SCHEMATIC_CIPHER_KEY_LENGTH']
      @options[:issuer] = ENV['SCHEMATIC_CIPHER_ISSUER']
    end
  end
end
