# frozen-string-literal: true

require "sequel"
require "sequel/core"

Sequel.extension :migration

require_relative 'migrator/core'
require_relative 'migrator/create'
require_relative 'migrator/info'
require_relative 'migrator/migrate'
