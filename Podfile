# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def app
  pod 'Masonry', '>=1.1.0'
  pod 'AFNetworking'
end

def common
   pod 'CocoaAsyncSocket'
   pod "CocoaLumberjack"
   pod 'ShadowSocks-libev-iOS', :git => 'git@github.com:juvham/ShadowSocks-libev-iOS.git', :tag => 'master'
   pod 'PacketProcessor_iOS'
end

target 'Lettuce Browser' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  common
    app
end

target 'LBFlashVPN' do
  use_frameworks!
  common
  pod 'ReachabilitySwift'
end
