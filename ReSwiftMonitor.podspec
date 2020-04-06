Pod::Spec.new do |s|
  s.name         = "ReSwiftMonitor"
  s.version      = "0.0.11"
  s.summary      = "ReSwift+redeux dev tools"
  s.homepage     = "https://github.com/takuchantuyoshi/ReSwiftMonitor"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "takuchantuyoshi" => "da87435@gmail.com" }
  s.source       = { :git => "https://github.com/takuchantuyoshi/ReSwiftMonitor.git", :tag => "#{s.version}" }
  s.ios.deployment_target = "9.0"
  s.requires_arc          = true
  s.source_files = "Sources/**/*.{swift}", "Sources/*.{swift,h}"
  s.dependency 'ReSwift', '~> 5.0.0'
  s.dependency 'HandyJSON', '~> 5.0.1'
  s.dependency 'Starscream', '3.1.1'
  s.swift_version = '5.0'
end
