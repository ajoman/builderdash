%w(
  build
  dropoff
  post_hooks
  pre_hooks
  touchdown
  upload
).each do |task|
  load "dash/tasks/#{task}.rake"
end
