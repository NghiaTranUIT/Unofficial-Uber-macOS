#
#   Created by : Nghia Tran
#
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.12'
workspace 'UberGoWorkspace.xcworkspace'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

# Pods
def important_pods

    # Core
    pod 'Alamofire'
    pod 'Unbox'
    pod 'Wrap'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'SwiftLint'
    pod 'OAuthSwift'
    pod 'SwiftyBeaver'
    pod 'MapboxDirections.swift', :git => 'https://github.com/NghiaTranUIT/MapboxDirections.swift', :branch => 'swift4'
end

# UberGo
target "UberGo" do
  project 'UberGo/UberGo.xcodeproj'
  important_pods
end

# UberGoCore
target "UberGoCore" do
  project 'UberGoCore/UberGoCore.xcodeproj'
  important_pods
end

# UberGoCoreTests
target "UberGoCoreTests" do
  project 'UberGoCore/UberGoCore.xcodeproj'
  important_pods
end

# UberGoTests
target "UberGoTests" do
  project 'UberGo/UberGo.xcodeproj'
  important_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
