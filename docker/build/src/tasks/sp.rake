require_relative '../lib/schematic/sp'

namespace :sp do
  desc "Create a stored procedure template file "
  task :create, :name do |_, args|
    unless args.name
      abort 'Aborted! Stored procedure name is missing.'
      exit 1
    end

    Schematic::Sp.new.create(args.name)
  end

  desc "Apply stored procedures"
  task :deploy do |_, args|
    Schematic::Sp.new.deploy
  end
end