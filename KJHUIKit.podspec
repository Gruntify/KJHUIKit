Pod::Spec.new do |s|
  s.name         = "KJHUIKit"
  s.version      = "0.9.1"
  s.summary      = "A handy set of views and buttons for iOS"
  s.homepage     = "https://github.com/KieranHarper/KJHUIKit.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Kieran Harper" => "kieranjharper@gmail.com" }
  s.social_media_url   = "https://twitter.com/KieranTheTwit"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/KieranHarper/KJHUIKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.dependency "SnapKit"
end
