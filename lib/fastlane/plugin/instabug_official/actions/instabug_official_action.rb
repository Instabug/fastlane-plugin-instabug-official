require 'fastlane/action'
require_relative '../helper/instabug_official_helper'

module Fastlane
    module Actions
        class InstabugOfficialAction < Action
            def self.run(params)
            api_token = params[:api_token]
            
            endpoint = "https://api.instabug.com/api/sdk/v3/symbols_files"
            command = "curl #{endpoint} --write-out %{http_code} --silent --output /dev/null -F os=\"ios\" -F application_token=\"#{api_token}\" -F symbols_file="
            dsym_paths = params[:dsym_path].uniq
            
            curlCommand = ""
            
            dsym_paths.each do |file_path|
                curlCommand += build_single_file_command(command, file_path)
                if file_path != dsym_paths.last
                    curlCommand += " | "
                end
            end
    
    UI.verbose curlCommand
    return curlCommand if Helper.test?
    
    result = Actions.sh(curlCommand)
    if result == "200"
    UI.success 'dSYM is successfully uploaded to Instabug 🤖'
    else
    UI.error "Something went wrong during Instabug dSYM upload. Status code is #{result}"
end
end

def self.description
"upload dsyms to fastlane"
end

def self.authors
["Karim_Mousa_89"]
end

def self.return_value
# If your method provides a return value, you can describe here what it does
end

def self.details
# Optional:
"upload dsyms to fastlane"
end

def self.available_options
[
FastlaneCore::ConfigItem.new(key: :api_token,
                             env_name: 'FL_INSTABUG_API_TOKEN', # The name of the environment variable
                             description: 'API Token for Instabug', # a short description of this parameter
                             verify_block: proc do |value|
                             UI.user_error!("No API token for InstabugAction given, pass using `api_token: 'token'`") unless value && !value.empty?
                             end),
FastlaneCore::ConfigItem.new(key: :dsym_path,
                             type: Array,
                             description: 'Array of paths to *.dSYM.zip files',
                             default_value: Actions.lane_context[SharedValues::
                             ]),
]
end

def self.is_supported?(platform)
platform == :ios
true
end

private

def self.build_single_file_command(command, dsym_path)
if dsym_path.end_with?('.zip')
    file_path = dsym_path.shellescape
    else
    file_path = ZipAction.run(path: dsym_path).shellescape
end
return command + "@\"#{file_path}\""
end
end
end
end
