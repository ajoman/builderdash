require 'mustache'

desc 'Generates a default Dashfile with minimum project setup'
namespace :dropoff do
  task :ios do
    dropoff_dashfile_from_template('ios')
  end
  task :android do
    dropoff_dashfile_from_template('android')
  end
end

def dropoff_dashfile_from_template(platform)
  if File.exists?('Dashfile')
    puts '[Drop Off] Dashfile already exists and won\'t be overwritten, for your peace of mind.'
  else
    File.open('Dashfile', 'w') do |file|
      file.write(File.read(File.expand_path("../../templates/#{platform}/Dashfile.template", __FILE__)))
    end
  end
end
