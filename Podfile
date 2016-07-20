# Uncomment this line to define a global platform for your project
platform :ios, "8.0"
# Uncomment this line if you're using Swift
use_frameworks!

xcodeproj 'Stappy2.xcodeproj'

def shared_pods
    pod 'DKDBManager'
    pod 'DKHelper'
    pod 'Mantle', '~>2.0'
    pod 'AFNetworking', '~> 3.1'
    pod 'SDWebImage', '~>3.7'
    pod 'SVPullToRefresh'
    pod 'MLPAutoCompleteTextField', '~>1.5'
    pod 'MCDateExtensions', :git => 'https://github.com/mirego/MCDateExtensions.git'
    pod 'NSDate+Calendar'
    pod 'SMSegmentView', '~> 1.1'
    pod 'Google/Analytics'
    pod 'FBSDKCoreKit', '~> 4.12'
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'Stappy2' do
    shared_pods
end

#target 'Schwedt' do
#    shared_pods
#end

target 'Stappy2Tests' do

end

target 'Stappy2UITests' do

end

