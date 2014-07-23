module Dash

  require 'rake'
  require 'dash/tasks'

  autoload :Dashfile, 'dash/dashfile'

  def self.takeoff(args)
    case args[0]
    when 'pre-hooks'
      dashfile = Dashfile.load
      Rake::Task['post_hooks'].invoke(dashfile.hooks_options)
    when 'build', 'upload'
      dashfile = Dashfile.load
      dashfile.build_instances.each do |build_instance|
        Rake::Task[args[0]].invoke(dashfile.build_specs, build_instance)
      end
    when 'post-hooks'
      dashfile = Dashfile.load
      Rake::Task['post_hooks'].invoke(dashfile.hooks_options)
    when 'touchdown'
      dashfile = Dashfile.load
      Rake::Task['pre_hooks'].invoke(dashfile.hooks_options)
      dashfile.build_instances.each do |build_instance|
        Rake::Task['touchdown'].invoke(dashfile.build_specs, build_instance)
      end
      Rake::Task['post_hooks'].invoke(dashfile.hooks_options)
    when /^dropoff/
      Rake::Task[args[0]].invoke
    else
      dashfile = Dashfile.load
      dashfile.build_instances.each do |build_instance|
        Rake::Task[args[0]].invoke(dashfile.build_specs, build_instance)
      end
    end
  end
end
