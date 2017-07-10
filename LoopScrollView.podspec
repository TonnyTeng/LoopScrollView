
Pod::Spec.new do |s|


  s.name         = "LoopScrollView"
  s.version      = "0.0.1"
  s.summary      = "LoopScrollView"

  s.description  = <<-DESC
 this is a LoopScrollView 
                   DESC

  s.homepage     = "https://github.com/TonnyTeng/LoopScrollView"

  s.license      = "MIT"

  s.author             = { "dengtao" => "1083683360@qq.com" }


  s.ios.deployment_target = '8.0'


  s.source       = { :git => "https://github.com/TonnyTeng/LoopScrollView.git", :tag => s.version}

  s.source_files  = “LoopScrollView”,”LoopScrollView/*.{h,m}”

  s.framework  = "UIKit"
  s.requires_arc = true

end
