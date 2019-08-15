#
# Be sure to run `pod lib lint LivePlayerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LivePlayerView'
  s.version          = '0.1.1'
  s.summary          = '基于金山直播SDK二次封装的播放器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  金山直播SDK二次封装的播放器，集成了远程控制，网络状态检测，播放器各状态变化都有对应的代理方法调用
                       DESC

  s.homepage         = 'https://github.com/RickwangF/LivePlayerView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RickwangF' => 'https://github.com/RickwangF' }
  s.source           = { :git => 'https://github.com/RickwangF/LivePlayerView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LivePlayerView/Classes/**/*'
  #s.vendored_libraries = 'LivePlayerView/*.{framework}'

  # s.resource_bundles = {
  #   'LivePlayerView' => ['LivePlayerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'KSYMediaPlayer_iOS', '~> 3.0.3'
  s.static_framework = true
end
