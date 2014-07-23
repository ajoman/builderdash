require 'tempfile'
require 'openssl'
require 'yaml'

module Dash

  class Build

    def self.install_signing_for_ios(build_specs, build_instance)
      path = "#{build_instance.signing_assets_params[:path]}/#{build_instance.target}"
      unless File.exists?("#{path}/config.yml")
        puts "[Build] Signing assets not found at #{path}. Aborting."
        exit(-1)
      end
      signing_assets = YAML.load_file("#{path}/config.yml")
      fetch_code_signing_identity(path, build_instance.settings)
      # Install certificate.
      default_keychain = `security default-keychain`.strip
      installation_file = "#{path}/#{signing_assets['certificate']['file_name']}"
      installation_password = signing_assets['certificate']['password']
      puts '[Build] security import: ' + `security import #{installation_file} -P #{installation_password} -k #{default_keychain}`
      # Install provisioning profile.
      installation_file = "#{path}/#{signing_assets['provisioning_profile']['file_name']}"
      uuid = fetch_provisioning_profile_uuid(installation_file)
      FileUtils.cp(installation_file, File.expand_path("#{ENV["HOME"]}/Library/MobileDevice/Provisioning Profiles/#{uuid}.mobileprovision"))
    end

    def self.compile_for_ios(build_specs, build_instance)
      build_command = "xcodebuild -scheme #{build_specs.scheme} -workspace #{build_specs.workspace}.xcworkspace -sdk iphoneos clean build"
      build_green_light = false
      puts "[Build] Target '#{build_instance.target}'..."
      build_instance.settings['DEVELOPER_DIR'] = ENV['DEVELOPER_DIR'] ||= `xcode-select --print-path`.strip
      build_instance.settings['ONLY_ACTIVE_ARCH'] = ENV['ONLY_ACTIVE_ARCH'] ||= 'YES'
      build_instance.settings['CONFIGURATION'] = ENV['CONFIGURATION'] ||= build_instance.configuration.to_s.capitalize
      build_instance.settings['CONFIGURATION_BUILD_DIR'] = "#{Dir.pwd}/build/#{build_instance.settings['CONFIGURATION']}-iphoneos"
      case build_instance.signing_assets_location
      when :fixed
        puts "[Build] Leaving PROVISIONING_PROFILE and CODE_SIGN_IDENTITY untouched."
        build_green_light = true
      when :local, :svn, :s3
        path = "#{build_instance.signing_assets_params[:path]}/#{build_instance.target}"
        if File.exists?(path)
          fetch_code_signing_identity(path, build_instance.settings)
          build_green_light = true
        else
          puts "[Build] Signing assets not found at #{path}."
        end
      else
        puts "[Build] Cannot build target '#{build_instance.target}': Unsupported signing assets location '#{build_instance.signing_assets_location}'."
      end
      unless build_green_light
        exit(-1)
      end
      # Let's go!
      current_build_command = inject_build_settings(build_command, build_instance.settings)
      output = `#{current_build_command} 2>&1`
      if $?.exitstatus > 0
        dump_full_output = true
        puts "[Build] Something went wrong."
        puts "[Build] Dumping output:\n#{output}" if dump_full_output
        exit(-1)
      end
      puts "[Build] Done with '#{build_instance.target}'."
    end

    private

    def self.fetch_code_signing_identity(path, settings)
      signing_assets = YAML.load_file("#{path}/config.yml")
      settings['PROVISIONING_PROFILE'] = fetch_provisioning_profile_uuid("#{path}/#{signing_assets['provisioning_profile']['file_name']}")
      settings['CODE_SIGN_IDENTITY'] = fetch_certificate_identity("#{path}/#{signing_assets['certificate']['file_name']}", signing_assets['certificate']['password'])
    end

    def self.fetch_provisioning_profile_uuid(filename)
      uuid = nil
      unless File.exists?(filename)
        print "Unable to find provisioning profile at #{filename}\n"
        exit(-1)
      end
      begin
        tmp_file = Tempfile.new(["mobileprovision", ".plist"])
        `security cms -D -i #{filename} > #{tmp_file.path}`
        uuid = `/usr/libexec/PlistBuddy -c "Print :UUID" #{tmp_file.path}`.strip
      rescue
        print "Unable to fetch provisioning profile UUID from #{filename}\n"
        exit(-1)
      ensure
        tmp_file.close
        tmp_file.unlink
      end
      uuid
    end

    def self.fetch_certificate_identity(filename, password)
      identity = nil
      unless File.exists?(filename)
        print "Unable to find certificate at #{filename}\n"
        exit(-1)
      end
      begin
        p12 = OpenSSL::PKCS12.new(File.read(filename), password)
        certificate = OpenSSL::X509::Certificate.new(p12.certificate)
        certificate.subject.to_a.each do |name_entry|
          if name_entry[0] == 'CN'
            identity = name_entry[1]
            break
          end
        end
      rescue Exception => e
        print "Unable to fetch certificate identity from #{filename} (#{e})\n"
        exit(-1)
      end
      identity
    end

    # Adds build settings to 
    # 
    # @param  [String] command
    # 
    # @param  [Hash] build_settings
    # 
    # @return [String]
    # 
    def self.inject_build_settings(command, build_settings)
      injected_command = "#{command}"
      build_settings.each do |key, value|
        injected_command << " #{key}=\"#{value}\""
      end
      injected_command
    end
  end
end
