module Dash
  class BuildSpecs
    attr_reader :platform
    attr_accessor :scheme, :workspace, :product_path, :product_name, :build_tool

    def initialize(name)
      @platform = name
    end
  end
end
