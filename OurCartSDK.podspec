#
#  Be sure to run `pod spec lint OurCartSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  #1.
          s.name               = "OurCartSDK"
          #2.
          s.version            = "1.0.0"
          #3.  
          s.summary         = "Sort description of 'OurCartSDK' framework"
          #4.
          s.homepage        = "http://www.ourcart.com"
          #5.
          s.license              = "MIT"
          #6.
          s.author               = "Damien Rotemberg"
          #7.
          s.platform            = :ios, "9.0"
          #8.
          s.source              = { :git => "https://github.com/drottemberg/testpod.git", :tag => "1.0.0" }
          #9.
          s.source_files     = "OurCartSDK", "OurCartSDK/**/*.{h,m,swift}"
  s.dependency 'Alamofire'
  s.dependency 'SwiftSoup'
  s.dependency 'UIImage-ResizeMagick'
  s.dependency 'AWSS3'

end
