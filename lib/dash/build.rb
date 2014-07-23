require 'dash/build/ios'
require 'dash/build/android'

require 'fog'

module Dash

  class Build

    def self.download_signing(build_specs, build_instance)
      case build_instance.signing_assets_location
      when :fixed, :local
        # Nothing to download. Signing assets expected to be found locally.
      when :svn
        download_signing_from_svn(build_instance)
      when :s3
        download_signing_from_aws_s3(build_instance)
      end
    end

    def self.install_signing(build_specs, build_instance)
      case build_specs.platform
      when :ios
        install_signing_for_ios(build_specs, build_instance) unless build_instance.signing_assets_location == :fixed
      when :android
        # Nothing to install. Signing assets for Android will be found in the current working directory.
      end
    end

    def self.compile(build_specs, build_instance)
      case build_specs.platform
      when :ios
        compile_for_ios(build_specs, build_instance)
      when :android
        compile_for_android(build_specs, build_instance)
      end
    end

    private

    def self.download_signing_from_svn(build_instance)
      `svn export https://svn.mmip.es/mobiguo/ci-commons/certs/#{build_instance.target} #{build_instance.signing_assets_params[:path]}/#{build_instance.target} --force --username #{build_instance.signing_assets_params[:username]} --password #{build_instance.signing_assets_params[:password]}`
    end

    def self.download_signing_from_aws_s3(build_instance)
      storage = Fog::Storage.new({:provider => 'AWS', :aws_access_key_id => build_instance.signing_assets_params[:access_key_id], :aws_secret_access_key => build_instance.signing_assets_params[:secret_access_key]})
      path = "#{build_instance.signing_assets_params[:path]}/#{build_instance.target}"
      remote_file = storage.directories.get(build_instance.signing_assets_params[:bucket], prefix: "#{path}/config.yml").files.first
      unless remote_file
        puts "[Install Signing] Assets not found at #{path} with location #{build_instance.signing_assets_location}."
        exit(-1)
      end
      FileUtils.mkdir_p path
      File.open(remote_file.key, 'w') do |local_file|
        local_file.write(remote_file.body)
      end
      config = YAML.load(remote_file.body)
      [ config['certificate']['file_name'], config['provisioning_profile']['file_name'] ].each do |filename|
        remote_file = storage.directories.get(build_instance.signing_assets_params[:bucket], prefix: "#{path}/#{filename}").files.first
        # Store locally the file retrieved from the bucket.
        File.open(remote_file.key, 'w') do |local_file|
          local_file.write(remote_file.body)
        end
      end
    end
  end
end
