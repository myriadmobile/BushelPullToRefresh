#
# Be sure to run `pod lib lint BushelRefresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  # Pod Information
  s.name             = 'BushelRefresh'
  s.version          = '1.1.0'
  s.summary          = 'An iOS Pull-To-Refresh and Infinite Scrolling library.'
  s.homepage         = 'https://github.com/myriadmobile/BushelRefresh'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Larson' => 'alarson@bushelpowered.com' }
  s.source           = { :git => 'https://github.com/myriadmobile/BushelRefresh.git', :tag => s.version.to_s }
  s.description      = <<-DESC
  BushelRefresh is an iOS Pull-To-Refresh and InfiniteScrolling library based on SVPullToRefresh. It has been rewritten in Swift and aims to address bugs we experienced with the original.
                       DESC

  # Configuration
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.3'

  # Source
  s.source_files = 'BushelRefresh/Classes/**/*'
  s.resource_bundle =  { 'BushelRefresh' => ['BushelRefresh/Assets/**/*.{xib,storyboard,png,jpeg,jpg,txt,ttf,xcassets,json}'] }

end
