Pod::Spec.new do |spec|

  	spec.name         = "JY_GeneralDevelopmentTools"
  	spec.version      = "1.0.0"
  	spec.summary      = "我自己用的通用开发工具"
  	spec.homepage     = "https://github.com/JYYQLin/JY_GeneralDevelopmentTools"
  	spec.license      = { :type => "MIT", :file => "LICENSE" }
  	spec.author       = { "JYYQLin" => "No mailBox" }
  	spec.platform     = :ios, "13.0"
  	spec.source       = { :git => "https://github.com/JYYQLin/JY_GeneralDevelopmentTools", :tag => "#{spec.version}" }
  	spec.source_files  = "JY_Tools/**/*.{h,m,swift}"
	spec.swift_versions = ['5.0', '5.1', '5.2']

end
