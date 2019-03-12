Pod::Spec.new do |s|
  s.name         = "ReSwiftMonitor"
  s.version      = "0.0.3"
  s.summary      = "ReSwift+redeux dev tools"
  s.homepage     = "https://github.com/takuchantuyoshi/ReSwiftMonitor"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "takuchantuyoshi" => "da87435@gmail.com" }
  s.source       = { :git => "https://github.com/takuchantuyoshi/ReSwiftMonitor.git", :tag => "#{s.version}" }
  s.ios.deployment_target = "9.0"
  s.requires_arc          = true
  s.source_files = "Sources/**/*.{swift}", "Sources/*.{swift,h}"
  s.dependency 'ReSwift', '~> 4.0.0'
  s.dependency 'HandyJSON', '~> 4.2.0'
  s.dependency 'Starscream', '~> 3.0.2'
end
