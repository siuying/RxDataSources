platform :ios, '10.0'
use_frameworks!

target 'RxDataSources' do
    pod 'RxSwift', git: "https://github.com/ReactiveX/RxSwift.git", branch: "swift-3.0"
    pod 'RxCocoa', git: "https://github.com/ReactiveX/RxSwift.git", branch: "swift-3.0"
end

target 'Example' do
  pod 'RxSwift', git: "https://github.com/ReactiveX/RxSwift.git", branch: "swift-3.0"
  pod 'RxCocoa', git: "https://github.com/ReactiveX/RxSwift.git", branch: "swift-3.0"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
      
      # workaround CocoaPods+Xcode 8 b2 "Found an unexpected Mach-O header code: 0x72613c21"
      config.build_settings['EMBEDDED_CONTENT_CONTAINS_SWIFT'] = 'NO'      
    end
  end
end
