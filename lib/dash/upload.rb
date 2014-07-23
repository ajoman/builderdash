require 'dash/upload/ios'
require 'dash/upload/android'

module Dash

  class Upload

    def self.run(build_specs, build_instance)
      case build_specs.platform
      when :ios
        upload_for_ios(build_specs, build_instance)
      when :android
        upload_for_android(build_specs, build_instance)
      end
    end

    private

    def self.upload_to_hockeyapp(build_instance, path, payload, release_version, build_number)
      begin
        latest_version = nil
        tmp_file = Tempfile.new(['versions', '.json'])
        puts '[Upload] Looking for latest version.'
        `curl -o #{tmp_file.path} --silent -X GET -H \"Accept-Charset: UTF-8\" -H \"X-HockeyAppToken: #{build_instance.upload_params[:team_token]}\" https://rink.hockeyapp.net/api/2/apps/#{build_instance.upload_params[:app_id]}/app_versions`
        all_versions = nil
        File.open(tmp_file, 'r:UTF-8') do |file|
          all_versions = JSON.parse(file.read)
        end
        all_versions['app_versions'].each do |version|
          # The latest upload has to have the same build number (exactly as in iTunes Connect) and the same tags.
          latest_version = version if latest_version == nil || (version['version'] == build_number && version['restricted_to_tags'] && !(version['tags'] & build_instance.upload_params[:tags]).empty?)
        end
        requests = []
        log_message = nil
        if latest_version && (latest_version['version'] == build_number) && build_instance.upload_params[:replace]
          # Delete first. This is done so to force HockeyApp (mobile app) to show the date of the latest upload.
          requests << { 'method' => 'DELETE', 'resource' => "app_versions/#{latest_version['id']}" }
          log_message = "Replacing version #{release_version} (#{build_number}) of #{Time.at(latest_version['timestamp']).strftime('%c')}"
        elsif latest_version && (latest_version['version'] == build_number) && !build_instance.upload_params[:replace]
          log_message = "Uploading version #{release_version} (#{build_number})"
        elsif latest_version && (latest_version['version'] != build_number)
          log_message = "Uploading new version #{release_version} (#{build_number})"
        end
        # Actually update the app.
        requests << { 'method' => 'POST', 'resource' => 'app_versions/upload' }
        puts "[Upload] #{log_message}"
        requests.each do |request|
          `curl --silent -X #{request['method']} -H \"X-HockeyAppToken: #{build_instance.upload_params[:team_token]}\" #{payload.map { |x| "-F \"#{x}\" " }.join} https://rink.hockeyapp.net/api/2/apps/#{build_instance.upload_params[:app_id]}/#{request['resource']}`
        end
      rescue
        puts "[Upload] Unable to upload to HockeyApp (#{$!})"
      ensure
        tmp_file.close
        tmp_file.unlink
      end
    end
  end
end
