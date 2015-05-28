source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

def various
    pod 'MBProgressHUD', '~> 0.8'
    pod 'PromiseKit', '1.4.1'
end

def analytics
    pod 'GoogleAnalytics-iOS-SDK', '~> 3.10'
end

def gigya
    pod 'Gigya-iOS-SDK'
end

def testing
    
    pod 'Expecta', '~> 0.2.4'
    pod 'OCMock', '~> 3.1'
    
end

workspace 'StarzPlayer.xcworkspace'

target :'StarzPlayer', :exclusive => true do
    xcodeproj 'StarzPlayer.xcodeproj'

    gigya
    analytics
    various
end


target 'StarzPlayerTests' , :exclusive => true do
   xcodeproj 'StarzPlayer.xcodeproj'
    testing
    
end


