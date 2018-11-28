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
  pod 'SwiftyJSON'
  pod 'Kingfisher'
  pod 'lottie-ios'
  pod 'GlidingCollection'
  pod 'EasyTransitions'
  pod 'SwiftEntryKit', '0.7.2'
  pod 'Armchair'
  pod 'Siren'
  pod 'SwiftKeychainWrapper'
  pod 'Instructions'
  pod 'NVActivityIndicatorView'
  pod 'SwiftyPickerPopover'

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
