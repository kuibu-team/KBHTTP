Pod::Spec.new do |spec|
  spec.name         = "KBHTTP"
  spec.version      = "1.0-rc"
  spec.summary      = "以接口的维度来封装请求"
  spec.description  = <<-DESC
                      以接口的维度来封装请求，以便使用和维护
                      DESC
  spec.homepage     = "https://github.com/kuibu-team/KBHTTP"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "DancewithPeng" => "dancewithpeng@gmail.com" }
  spec.source       = { :git => "https://github.com/kuibu-team/KBHTTP.git", :tag => "#{spec.version}" }
  spec.source_files = "KBHTTP/Sources", "KBHTTP/Sources/**/*.{swift,h}"
end
