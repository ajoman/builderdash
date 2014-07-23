module Dash

  class Build

    def self.compile_for_android(build_specs, build_instance)
      path = "#{build_instance.signing_assets_params[:path]}/#{build_instance.target}"
      unless File.exists?("#{path}/config.yml")
        puts "[Build] Signing assets not found at #{path}. Aborting."
        exit(-1)
      end
      signing_assets = YAML.load_file("#{path}/config.yml")
      build_instance.settings['ANDROID_HOME'] = ENV['ANDROID_HOME']
      build_instance.settings['CONFIGURATION'] = ENV['CONFIGURATION'] ||= build_instance.configuration.to_s.downcase
      build_instance.settings['KEYSTORE'] = "#{Dir.pwd}/#{path}/#{signing_assets['certificate']['key_store']}"
      build_instance.settings['STOREPASS'] = signing_assets['certificate']['key_store_password']
      build_instance.settings['ALIAS'] = signing_assets['certificate']['alias']
      build_instance.settings['KEYPASS'] = signing_assets['certificate']['alias_password']
      case build_specs.build_tool
      when :maven
        build_command = "mvn clean package -f \"#{build_specs.product_path}/pom.xml\" -Dsdk.dir=\"#{build_instance.settings['ANDROID_HOME']}\" -P#{build_instance.settings['CONFIGURATION']} -Dsign.keystore=\"#{build_instance.settings['KEYSTORE']}\" -Dsign.storepass=\"#{build_instance.settings['STOREPASS']}\" -Dsign.alias=\"#{build_instance.settings['ALIAS']}\" -Dsign.keypass=\"#{build_instance.settings['KEYPASS']}\""
        current_build_command = inject_build_path(build_command, ENV['MAVEN_HOME'])
      when :ant
        build_command = "ant clean #{build_instance.settings['CONFIGURATION']}"
        current_build_command = inject_build_path(build_command, ENV['ANT_HOME'])
      when :gradle
        build_command = "sh gradlew build -PkeyStore=\"#{build_instance.settings['KEYSTORE']}\" -PkeyStorePassword=\"#{build_instance.settings['STOREPASS']}\" -PkeyAlias=\"#{build_instance.settings['ALIAS']}\" -PkeyAliasPassword=\"#{build_instance.settings['KEYPASS']}\""
        current_build_command = build_command
      end
      # Let's go!
      puts "[Build] #{current_build_command}"
      output = `#{current_build_command} 2>&1`
      if $?.exitstatus > 0
        dump_full_output = true
        puts "[Build] Something went wrong."
        puts "[Build] Dumping output:\n#{output}" if dump_full_output
        exit(-1)
      end
      puts "[Build] Done with '#{build_instance.target}'."
    end

    def self.inject_build_path(command, path)
      if path
        injected_command = "#{path}/bin/#{command}"
      else
        injected_command = command
      end
      injected_command
    end
  end
end
