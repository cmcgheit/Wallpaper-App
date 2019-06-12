# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'Wallpaper-App' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Wallpaper-App
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/AdMob'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyJSON', '4.2.0'
  pod 'Kingfisher', '5.1.1'
  pod 'lottie-ios', '3.0.7'
  pod 'GlidingCollection'
  pod 'CropViewController'
  pod 'SwiftEntryKit', '0.8.9'
  pod 'Armchair'
  pod 'Siren', :git => 'https://github.com/ArtSabintsev/Siren.git', :branch => 'swift4.2'
  pod 'SwiftKeychainWrapper', '3.2.0'
  pod 'Instructions', '1.2.2'
  pod 'NVActivityIndicatorView', '4.6.1'
  pod 'SwiftyPickerPopover', '6.6.5'

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'Armchair'
              target.build_configurations.each do |config|
                  if config.name == 'Debug'
                      config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDebug'
                      else
                      config.build_settings['OTHER_SWIFT_FLAGS'] = ''
                  end
              end
          end
      end
  end

  # post_install do |installer|
  #     installer.pods_project.targets.each do |target|
  #         target.build_configurations.each do |config|
  #             config.build_settings['SWIFT_VERSION'] = '3.0'
  #         end
  #     end
  # end

#  post_install do |installer|
#      installer.pods_project.targets.each do |target|
#          if ['Kingfisher', 'RxSwift', 'RxCocoa'].include? target.name
#              target.build_configurations.each do |config|
#                  config.build_settings['SWIFT_VERSION'] = '3.2'
#              end
#          end
#      end
#  end

end
