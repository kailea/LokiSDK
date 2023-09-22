# Uncomment the next line to define a global platform for your project
platform :ios, '15.1'
#plugin 'cocoapods-binary'
target 'LokiSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
	use_frameworks!

  # Pods for LokiSDK
	pod 'Alamofire'
	pod 'AzureIoTUtility'
	pod 'AzureIoTuMqtt'
	pod 'AzureIoTuAmqp'
	pod 'AzureIoTHubClient'
	pod 'OpenSSL-Universal'
	pod 'DeviceKit'
	pod 'Swinject'

  target 'LokiSDKTests' do
    # Pods for testing
  end

end


post_install do |installer|
	installer.aggregate_targets.each do |target|
		target.xcconfigs.each do |variant, xcconfig|
			xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
			IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
		end
	end
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
				xcconfig_path = config.base_configuration_reference.real_path
				IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
			end
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
			config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
			config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
			config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
			config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.1'
		end
	end
end
