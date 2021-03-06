module DeviceDetector::Parser
  struct Browser
    include Helper

    getter kind = "browser"
    @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    class Browser
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String | Int32 | Float32?
    end

    def browsers
      return @@browsers if @@browsers
      @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml").gets_to_end)
    end

    def call
      detected_browser = {"name" => "", "version" => ""}
      browsers.reverse_each do |browser|
        if Regex.new(browser.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_browser.merge!({"name" => browser.name})
          unless browser.version.nil?
            if capture_groups?(browser.version.to_s)
              version = fill_groups(browser.version.to_s, browser.regex, @user_agent)
              detected_browser.merge!({"version" => version})
            else
              detected_browser.merge!({"version" => browser.version.to_s})
            end
          end
        end
      end
      detected_browser
    end
  end
end
