Pod::Spec.new do |s|
  s.name             = 'Number'
  s.version          = '0.1.2'
  s.summary          = '一个计算方便、容易扩展的数值计算库。'

  s.description      = <<-DESC
一个简单的数值计算的库，封装了系统的NSDecimalNumber，方便数值计算，避免精度的丢失。使用的时候可以直接对NSString、NSNumber、NSDecimalNumber类型的数做数值的加减乘除等运算。
                       DESC

  s.homepage         = 'https://github.com/JyHu/Number'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JyHu' => 'auu.aug@gmail.com' }
  s.source           = { :git => 'https://github.com/JyHu/Number.git', :tag => '0.1.1' }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.11'
  s.source_files = 'AUUNumber/*.{h,m}'
end
