

Pod::Spec.new do |spec|

  spec.name         = "IMHeartRateMonitor"
  spec.version      = "1.0.6"
  spec.summary      = "IMHeartRateMonitor is a lightweight library on top of Core Bluetooth to interact with BLE Heart Rate Monitors."
  spec.homepage     = "https://github.com/IgorMakara/IMHeartRateMonitor"

  spec.license      = "MIT"
  spec.author       = { "Igor Makara" => "igor1994makara@gmail.com" }

  # spec.platform   = :ios, "11.0"

  spec.source       = { :git => "https://github.com/IgorMakara/IMHeartRateMonitor.git", :tag => "1.0.6" }

  spec.source_files  = "IMHeartRateMonitor/IMHeartRateMonitor/Classes/**/*"

  spec.swift_versions = '4.0'
  spec.ios.deployment_target = '11.0'
  spec.exclude_files = "IMHeartRateMonitor/*.plist"
  
end
