module Dash

  class Upload

    def self.upload_for_ios(build_specs, build_instance)
      path = "#{build_instance.settings['CONFIGURATION_BUILD_DIR']}/#{build_specs.product_name}"
      `xcrun -sdk iphoneos PackageApplication -v \"#{path}.app\" -o \"#{path}.ipa\"`
      `zip -r #{path}.app.dSYM.zip #{path}.app.dSYM`
      case build_instance.upload_platform
      when :hockeyapp
        # Check requirements:
        # The 'agvtool what-version' looks for CURRENT_PROJECT_VERSION parameter, so it must be defined in the project or in its targets.
        raise 'CURRENT_PROJECT_VERSION undefined' if `agvtool what-version -terse`.strip.empty?
        payload = ['status=2', 'notify=0', "tags=#{build_instance.upload_params[:tags].join(',')}", "ipa=@#{path}.ipa", "dsym=@#{path}.app.dSYM.zip"]
        release_version = `agvtool what-marketing-version -terse1`.strip
        build_number = `agvtool what-version -terse`.strip
        upload_to_hockeyapp(build_instance, path, payload, release_version, build_number)
      else
      end
    end
  end
end
