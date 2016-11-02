Pod::Spec.new do |s|
  s.name         = "SWMessages"
  s.version      = "0.3.1"
  s.summary      = "A notification message view library"

  s.description  = <<-DESC
      This library provides an easy to use class to show
      little notification views on the top or bottom of the screen.
      DESC
  s.homepage     = "http://github.com/sai-prasanna/SWMessages"
  s.license      = "MIT"
  s.author       = { "Sai Prasanna" => "sai.r.prasanna@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/sai-prasanna/SWMessages.git", :tag => "v#{s.version}" }
  s.source_files = "SWMessages/Source/", "SWMessages/SWMessages.h"
  s.resources = "SWMessages/Assets/*.png"

end
