workspace 'KJHUIKit'
inhibit_all_warnings!
use_frameworks!


target 'KJHUIKit-iOS' do  
    platform :ios, '9.0'
    pod 'SnapKit', '~> 4.0.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SnapKit'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end