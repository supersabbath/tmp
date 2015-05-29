Pod::Spec.new do |s|
  s.name         = 'SPPlayer'
  s.version      = '1.0.3'
  s.summary      = 'DRM HLS Player'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.license          = 'MIT'
  s.author = {
    'Fernando Canon' => 'fernando.canon@starzplayarabia.com'
  }
  s.homepage  = 'https://github.com/supersabbath'
  s.source = {
    :git => "https://github.com/supersabbath/tmp.git" , :tag => '1.0.3' 
  }
  s.source_files = 'StarzPlayer/src/**/*.{h,m}', 'StarzPlayer/util/ui/UIButton+Player.?'
  s.resources = ["StarzPlayer/src/**/*.{h,m,xib}"]
  s.vendored_frameworks = 'StarzPlayer/frameworks/Player/PSDKLibrary.framework', 'StarzPlayer/frameworks/DRM/drmNativeInterface.framework'
  s.frameworks = 'UIKit', 'MediaPlayer', 'AVFoundation', 'CoreMedia', 'Security' , 'CoreGraphics', 'CFNetwork' ,'SystemConfiguration', 'MobileCoreServices'
  s.libraries = "z", "xml2.2" , "stdc++.6"
  s.xcconfig = {
    "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" ,
    "OTHER_LDFLAGS" => "-ObjC", 
    "OTHER_LDFLAGS" => "-all_load", 
    "OTHER_LDFLAGS" => "-lstdc++"
 }
  s.ios.dependency 'MBProgressHUD', '~> 0.8'
 #s.preserve_paths = "StarzPlayer/frameworks/**"
end
