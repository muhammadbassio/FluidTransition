Pod::Spec.new do |s|
  s.name             = 'FluidTransition'
  s.version          = '1.0'
  s.summary          = 'A customized Presentation stack for UIKit'
 
  s.description      = <<-DESC
A customized Presentation stack for UIKit to overcome https://openradar.appspot.com/29840481 (written in swift).
                       DESC
 
  s.homepage         = 'https://github.com/muhammadbassio/FluidTransition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhammad Bassio' => 'muhammadbassio@gmail.com' }
  s.source           = { :git => 'https://github.com/muhammadbassio/FluidTransition.git', :tag => s.version.to_s }
 
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
  s.ios.deployment_target = '11.0'
  s.source_files = 'source/*.swift'
 
end