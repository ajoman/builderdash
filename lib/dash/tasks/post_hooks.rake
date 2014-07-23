require 'dash/hooks'

desc 'Runs every Ruby script bundled with Builder Dash and found at hooks/post folder.'
task :post_hooks, [:hooks_options] do |t, args|
  Dash::Hooks.post(args.hooks_options)
end
