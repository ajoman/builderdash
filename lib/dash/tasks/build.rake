require 'dash/build'

desc ''
task :build, [:build_specs, :build_instance] => [:install_signing, :compile]

desc ''
task :install_signing, [:build_specs, :build_instance] => :download_signing do |t, args|
  Dash::Build.install_signing(args.build_specs, args.build_instance)
end

desc ''
task :download_signing, [:build_specs, :build_instance] do |t, args|
  Dash::Build.download_signing(args.build_specs, args.build_instance)
end

desc ''
task :compile, [:build_specs, :build_instance] do |t, args|
  Dash::Build.compile(args.build_specs, args.build_instance)
end
