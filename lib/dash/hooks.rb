module Dash

  class Hooks

    $stdout.sync = true
    RUBY = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

    def self.pre(hooks_options)
      run(hooks_options, 'pre')
    end

    def self.post(hooks_options)
      run(hooks_options, 'post')
    end

    private

    def self.run(hooks_options, folder)
      case hooks_options[:active]
      when :none, nil
        puts "[Hooks] All hooks disabled."
      when :all
        (Dir.glob("lib/dash/hooks/#{folder}/*.rb") | Dir.glob("hooks/#{folder}/*.rb")).each do |script|
          puts "[Hooks] Running #{script}..."
          output = `#{RUBY} #{script} 2>&1`
          puts "[Hooks] Finished. Dumping output:"
          output.split("\n").each { |output_line| puts "[Hooks]   #{output_line}" }
        end
      end
    end
  end
end
