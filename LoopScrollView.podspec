

Pod::Spec.new do |s|

  s.name         = "LoopScrollView"
  s.version      = "0.0.1"
  s.summary      = "LoopScrollView"
  s.description  = <<-DESC
this is loop scrollView 
                   DESC
  s.homepage     = "https://github.com/TonnyTeng/LoopScrollView"
  s.license      = "MIT"
  s.author       = { "dengtao" => "1083683360@qq.com" }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/TonnyTeng/LoopScrollView.git", :tag => “0.0.1” }
  s.source_files  = "LoopScrollView/**/*.{h,m}"
  s.framework  = “UIKit”
  s.requires_arc = true

end
