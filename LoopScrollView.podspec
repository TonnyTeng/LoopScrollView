
Pod::Spec.new do |s|


  s.name         = "LoopScrollView"
  s.version      = "0.0.1"
  s.summary      = "A short description of LoopScrollView."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/TonnyTeng/LoopScrollView"

  s.license      = "MIT"



  s.author             = { "dengtao" => "1083683360@qq.com" }


  s.platform     = :ios, “8.0”



  s.source       = { :git => "https://github.com/TonnyTeng/LoopScrollView.git", :tag => "{s.version}" }



  s.source_files  = "LoopScrollView", "LoopScrollView/*.{h,m}"

  s.framework  = "UIKit"
  s.requires_arc = true

end
