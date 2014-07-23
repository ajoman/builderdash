module Dash
  class BuildInstance
    attr_reader :target
    attr_accessor :configuration, :signing_assets_location, :signing_assets_params, :upload_platform, :upload_params, :settings

    def initialize(name)
      @target = name
      @settings = {}
    end
  end
end
