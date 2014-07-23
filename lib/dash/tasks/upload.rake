require 'dash/upload'

desc ''
task :upload, [:build_specs, :build_instance] => :build do |t, args|
  Dash::Upload.run(args.build_specs, args.build_instance)
end
