require 'nokogiri'

module Dash

  class Upload

    def self.upload_for_android(build_specs, build_instance)
      case build_specs.build_tool
      when :maven
        path = "#{Dir.pwd}/target/#{build_specs.product_name}"
      when :ant
        path = "#{Dir.pwd}/bin/#{build_specs.product_name}"
      when :gradle
        path = "#{Dir.pwd}/#{build_specs.product_path}/build/apk/#{build_specs.product_name}"
      end
      case build_instance.upload_platform
      when :hockeyapp
        payload = ['status=2', 'notify=0', "tags=#{build_instance.upload_params[:tags].join(',')}", "ipa=@#{path}.apk"]
        xml = Nokogiri::XML(File.read("#{build_specs.product_path}/AndroidManifest.xml"))
        release_version = xml.xpath('//manifest/@android:versionName').first.value
        build_number = xml.xpath('//manifest/@android:versionCode').first.value
        upload_to_hockeyapp(build_instance, path, payload, release_version, build_number)
      else
      end
    end
  end
end
