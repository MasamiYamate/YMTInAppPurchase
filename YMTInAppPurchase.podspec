#
#  Be sure to run `pod spec lint YMTVersionAlert.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
Pod::Spec.new do |s|
s.name         = "YMTInAppPurchase"
s.version      = "1.1"
s.summary      = "Framework to handle In-App Purchase"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.homepage     = "https://github.com/MasamiYamate/YMTInAppPurchaseFramework.git"
s.author       = { "MasamiYamate" => "yamate.inquiry@mail.yamatte.net" }
s.source       = { :git => "https://github.com/MasamiYamate/YMTInAppPurchaseFramework.git", :tag => "#{s.version}" }
s.platform     = :ios, "9.0"
s.requires_arc = true
s.source_files = 'YMTInAppPurchase/**/*.{swift}'
s.swift_versions = ['3.2', '4.0', '4.2' , '5.0']
end
