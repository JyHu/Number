#
# Be sure to run `pod lib lint Number.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Number'
  s.version          = '0.1.1'
  s.summary          = '一个计算方便、容易扩展的数值计算库。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
一个简单的数值计算的库，封装了系统的NSDecimalNumber，方便数值计算，避免精度的丢失。使用的时候可以直接对NSString、NSNumber、NSDecimalNumber类型的数做数值的加减乘除等运算。
                       DESC

  s.homepage         = 'https://github.com/JyHu/Number'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JyHu' => 'auu.aug@gmail.com' }
  # s.source 			 = { :git => '', :tag => '0.01'}
  s.source           = { :git => 'https://github.com/JyHu/Number.git', :tag => '0.1.1' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'AUUNumber/*.{h,m}'
  
  # s.resource_bundles = {
  #   'Number' => ['Number/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
