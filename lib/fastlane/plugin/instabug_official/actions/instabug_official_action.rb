require 'fileutils'
require 'fastlane/action'
require_relative '../helper/instabug_official_helper'
require 'shellwords'

module Fastlane
  module Actions
    class InstabugOfficialAction < Action
      def self.run(params)
        @instabug_dsyms_directory = 'Instabug_dsym_files_fastlane'

        UI.verbose 'Running Instabug Action'
        api_token = params[:api_token]

        endpoint = 'https://api.instabug.com/api/sdk/v3/symbols_files'
        command = "curl #{endpoint} --write-out %{http_code} --silent --output /dev/null -F os=\"ios\" -F application_token=\"#{api_token}\" -F symbols_file="

        dsym_paths = []
        # Add paths provided by the user
        dsym_paths += (params[:dsym_array_paths] || [])
        # Add dSYMs generaed by `gym`
        dsym_paths += [Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]] if Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]
        # Add dSYMs downloaded from iTC
        dsym_paths += Actions.lane_context[SharedValues::DSYM_PATHS] if Actions.lane_context[SharedValues::DSYM_PATHS]

        dsym_paths.uniq!
        UI.verbose 'dsym_paths: ' + dsym_paths.inspect

        if dsym_paths.empty?
          UI.error "Fastlane dSYMs file is not found! make sure you're using Fastlane action [download_dsyms] to download your dSYMs from App Store Connect"
          return
        end

        generate_instabug_directory

        UI.verbose 'Directory name: ' + @instabug_dsyms_directory
        copy_dsym_paths_into_directory(dsym_paths, @instabug_dsyms_directory)

        command = build_single_file_command(command, @instabug_dsyms_directory)

        result = Actions.sh(command)
        if result == '200'
          UI.success 'dSYM is successfully uploaded to Instabug 🤖'
          UI.verbose 'Removing The directory'
        else
          UI.error "Something went wrong during Instabug dSYM upload. Status code is #{result}"
        end

        # Cleanup zip file and directory
        cleanup_instabug_directory
      end

      def self.description
        "Upload dSYM files to Instabug"
      end
    
      def self.details
        "This action is used to upload symbolication files to Instabug. Incase you are not using bitcode, you can use this plug-in
        with `gym` to upload dSYMs generated from your builds. If bitcode is enabled, you can use it with `download_dsyms` to upload dSYMs
        from iTunes connect"
      end

      def self.authors
        ['Instabug Inc.']
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.example_code
        [
          'instabug_official(api_token: "<Instabug token>")',
          'instabug_official(api_token: "<Instabug token>", dsym_array_paths: ["./App1.dSYM.zip", "./App2.dSYM.zip"])'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: 'FL_INSTABUG_API_TOKEN', # The name of the environment variable
                                       description: 'API Token for Instabug', # a short description of this parameter
                                       verify_block: proc do |value|
                                                       unless value && !value.empty?
                                                         UI.user_error!("No API token for InstabugAction given, pass using `api_token: 'token'`")
                                                       end
                                                     end),
          FastlaneCore::ConfigItem.new(key: :dsym_array_paths,
                                       type: Array,
                                       optional: true,
                                       description: 'Array of paths to *.dSYM files')
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
        true
      end

      def self.generate_instabug_directory
        cleanup_instabug_directory
        FileUtils.mkdir_p @instabug_dsyms_directory
      end

      def self.cleanup_instabug_directory
        FileUtils.rm_f "#{@instabug_dsyms_directory}.zip"
        FileUtils.rm_rf @instabug_dsyms_directory
      end

      def self.remove_directory(directory_path)
        FileUtils.rm_rf directory_path
      end

      def self.copy_dsym_paths_into_directory(dsym_paths, directory_path)
        dsym_paths.each do |path|
          if File.extname(path) == '.dSYM'
            destination_path = "#{directory_path}/#{File.basename(path)}"
            FileUtils.copy_entry(path, destination_path) if File.exist?(path)
          else
            Actions.sh("unzip -n #{Shellwords.shellescape(path)} -d #{Shellwords.shellescape(directory_path)}")
          end
        end
      end

      def self.build_single_file_command(command, dsym_path)
        file_path = if dsym_path.end_with?('.zip')
                      dsym_path
                    else
                      ZipAction.run(path: dsym_path, include: [], exclude: [])
                    end
        command + "@\"#{file_path}\""
      end
    end
  end
end
