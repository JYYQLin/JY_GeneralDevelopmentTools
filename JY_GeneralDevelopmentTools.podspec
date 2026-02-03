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
	spec.resource_bundles = {
	    # Bundle 名称建议和组件名一致，方便后续代码里查找
	    "JY_GeneralDevelopmentTools" => [
	      "JY_Tools/Resources/**/*.xcassets",  # 包含所有 xcassets（包括 Color.xcassets）
	      "JY_Tools/Resources/Font/**/*"       # 包含 Font 文件夹下的所有字体文件
	    ]
	  }
	spec.swift_versions = ['5.0', '5.1', '5.2']

end
