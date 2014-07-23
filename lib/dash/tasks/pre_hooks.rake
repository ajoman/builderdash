require 'dash/hooks'

desc 'Runs every Ruby script bundled with Builder Dash and found at hooks/pre folder.'
task :pre_hooks, [:hooks_options] do |t, args|
  Dash::Hooks.pre(args.hooks_options)
end
