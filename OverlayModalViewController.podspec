#
# Be sure to run `pod lib lint OverlayModalViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OverlayModalViewController'
  s.version          = '0.3.0'
  s.summary          = 'A super class to help you present effects overlay view controller easyly.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Support different background effects with custom interface, and support pan gesture to help you dismiss view controller easyly.'

  s.homepage         = 'https://github.com/showang/OverlayModalViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'William Wang' => 'showang730@gmail.com' }
  s.source           = { :git => 'https://github.com/showang/OverlayModalViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'OverlayModalViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OverlayModalViewController' => ['OverlayModalViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
