# instabug_official plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-instabug_official)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-instabug_official`, add it to your project by running:

```bash
fastlane add_plugin instabug_official
```

## About instabug_official

Upload dSYM files to Instabug

This action is used to upload symbolication files to Instabug. Incase you are not using bitcode, you can use this plug-in
with `gym` to upload dSYMs generated from your builds. If bitcode is enabled, you can use it with `download_dsyms` to upload dSYMs
from iTunes connect

## Example

```
instabug_official(api_token: "<Instabug token>")
```

```
instabug_official(api_token: "<Instabug token>", dsym_array_paths: ["./App1.dSYM.zip", "./App2.dSYM.zip"])
```

If you are using the EU cluster in the SDK you need to use the `eu` parameter to upload to the EU cluster
```
instabug_official(api_token: "<Instabug token>", eu: true)
```

If you're using a custom endpoint please provide it using the `end_point` parameter as follows
```
instabug_official(api_token: "<Instabug token>", end_point: "https://api.instabug.com/api/sdk/v3/symbols_files")
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
