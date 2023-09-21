Pod::Spec.new do |s|  
    s.name              = 'LokiSDK' # Name for your pod
    s.version           = '1.0.0'
    s.summary           = 'LokiSDK'
    s.homepage          = 'https://www.google.com'

    s.author            = { 'Amandeep Kaile' => 'akaile@guardiancorp.com.au' }
    s.license = { :type => "MIT", :text => "MIT License" }

    s.platform          = :ios
    # change the source location
    s.source            = { :git => 'https://github.com/kailea/LokiSDK.git' } 
    s.ios.deployment_target = '10.0'
    s.ios.vendored_frameworks = 'LokiSDK.xcframework' # Your XCFramework
    s.dependency 'Alamofire'
    s.dependency 'AzureIoTUtility'
    s.dependency 'AzureIoTuMqtt'
    s.dependency 'AzureIoTuAmqp'
    s.dependency 'AzureIoTHubClient'
    s.dependency 'OpenSSL-Universal'
    s.dependency 'DeviceKit'
    s.dependency 'Swinject'
    s.swift_version = '5.0'
end