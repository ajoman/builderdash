require 'dash/build/specs'
require 'dash/build/instance'

module Dash

  class Dashfile

    module DSL

      def initialize
        @build_instances = []
        @hooks_options = {}
      end

      # Specifies the platform of the build.
      # 
      # By default, the build tool is `:xcodebuild` for platform `:ios` and
      # `:maven` for `:android`. Sets a default value if undefined.
      # 
      # @example
      #   platform :ios
      # 
      # @param   [Symbol] name
      #          the name of the platform, can be either `:ios` or `:android`.
      # 
      # @return  [void]
      # 
      def platform(name, params = {})
        @build_specs = BuildSpecs.new(name)
        case @build_specs.platform
        when :ios
          @build_specs.scheme = params[:scheme]
          @build_specs.workspace = params[:workspace]
          @build_specs.product_name = params[:product_name] ||= params[:scheme]
        when :android
          @build_specs.product_path = params[:product_path]
          @build_specs.build_tool = params[:build_tool] ||= :maven
        else
          raise ArgumentError, "Unsupported platform #{@build_specs.platform}. Please review your Dashfile."
        end
      end

      # @param   [Hash] options
      # 
      # @return  [void]
      # 
      def hooks(options = {})
        # By default, no hooks active.
        options[:active] ||= :none
        @hooks_options = options
      end

      # Specifies a target.
      # 
      # A target is defined by the name of the signee and optionally a list of
      # parameters.
      # 
      # You can specify the file that contains the assets for the signing, though
      # it will look for `config.yml` by default:
      # 
      #     signing 'team/speedjab', :assets => 'config.yml'
      # 
      # You can specify the configuration environment for the build, though it will
      # use `debug` by default:
      # 
      #     signing 'team/speedjab', :configuration => 'debug'
      # 
      # @example
      #   signing 'team/speedjab/enterprise', :assets => 'certs.yml', :configuration => 'release'
      # 
      # @example
      #   signing 'team/speedjab/enterprise', :assets => { :s3, }
      # 
      # @param   [String] name
      #          name of the signee in format of relative path starting at certs folder.
      # 
      # @param   [Hash {Symbol => String}] params
      #          a hash of parameters for the signing.
      # 
      # @option  params [String] :assets
      # 
      # @option  params [String] :configuration
      # 
      # @return  [void]
      # 
      def target(name)
        @build_instances << (@current_build_instance = BuildInstance.new(name))
        yield
      end

      def configuration(type)
        @current_build_instance.configuration = type
      end

      def signing_assets(location, params = {})
        # Set path to 'certs' by default.
        params[:path] ||= 'certs'
        # Set credentials from environment variables by default.
        case location
        when :svn
          params[:username] ||= ENV['SVN_USERNAME']
          params[:password] ||= ENV['SVN_PASSWORD']
        when :s3
          params[:access_key_id] ||= ENV['AWS_ACCESS_KEY']
          params[:secret_access_key] ||= ENV['AWS_SECRET_KEY']
        end
        @current_build_instance.signing_assets_location = location
        @current_build_instance.signing_assets_params = params
      end

      def upload(platform, params = {})
        @current_build_instance.upload_platform = platform
        @current_build_instance.upload_params = params
      end
    end
  end
end
