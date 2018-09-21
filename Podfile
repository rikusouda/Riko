# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Riko' do
  use_frameworks!
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'XCGLogger'
  pod 'RealmSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['SomeTarget-iOS', 'SomeTarget-watchOS'].include? "#{target}"
            print "Setting #{target}'s SWIFT_VERSION to 4.0\n"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        else
            print "Setting #{target}'s SWIFT_VERSION to Undefined (Xcode will automatically resolve)\n"
            target.build_configurations.each do |config|
                config.build_settings.delete('SWIFT_VERSION')
            end
        end
    end

    print "Setting the default SWIFT_VERSION to 3.2\n"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.2'
    end
end
