require 'dash/dashfile/dsl'

module Dash

  class Dashfile

    include Dash::Dashfile::DSL

    attr_reader :build_specs, :build_instances, :hooks_options

    def self.load
      unless File.exists?('Dashfile')
        raise ArgumentError, 'Dashfile not found in current working directory'
      end
      @dashfile = new
      @dashfile.instance_eval(File.read('Dashfile'), 'Dashfile')
      @dashfile
    end
  end
end
