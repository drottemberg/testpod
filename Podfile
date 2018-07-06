use_frameworks!

platform :ios, "9.0"


def sdk_pods
    pod 'Alamofire'
    pod 'SwiftSoup'
    pod 'UIImage-ResizeMagick'
    pod 'AWSS3'
 end


target 'OurCartSDK' do
    project 'OurCartSDK.xcodeproj'
    sdk_pods
end




post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'YES'
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end


