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
    pod 'Alamofire', '4.5'
    pod 'Unbox', '2.5'
    pod 'Wrap', '2.1.1'
    pod 'RxSwift',    '3.6.1'
    pod 'RxCocoa',    '3.6.1'
    pod 'SwiftLint', '0.21.0'
    pod 'OAuthSwift', '1.1.2'
    pod 'SwiftyBeaver', '1.4.0'
    pod 'MapboxDirections.swift', '0.10.4'
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
