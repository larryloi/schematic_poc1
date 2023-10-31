require_relative '../lib/schematic/job'

namespace :job do
  desc "Create job template files "
  task :create, :name do |_, args|
    unless args.name
      abort 'Aborted! job name is missing.'
      exit 1
    end

    Schematic::Job.new.create(args.name)
  end

  desc "Apply jobs"
  task :deploy do |_, args|
    Schematic::Job.new.deploy
  end
end