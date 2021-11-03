Pod::Spec.new do |spec|
    spec.name         = "KBHTTP"
    spec.version      = "1.0-rc"
    spec.summary      = "以接口的维度来封装请求"
    spec.description  = <<-DESC
                        以接口的维度来封装请求，以便使用和维护
                    DESC

    spec.homepage      = "https://github.com/kuibu-team/KBHTTP.git"
    spec.license       = { :type => "MIT", :file => "LICENSE" }
    spec.platform      = :ios, "12.0"
    spec.swift_version = '5.0'
    spec.author        = { "DancewithPeng" => "dancewithpeng@gmail.com" }    
    spec.source        = { :git => "https://github.com/kuibu-team/KBHTTP.git", :tag => "#{spec.version}" }

    spec.source_files = "KBHTTP/Sources", "KBHTTP/Sources/KBHTTP.h"

    spec.subspec 'Core' do |sp|
        sp.source_files = 'KBHTTP/Sources/Core/*.{swift}'
    end
      
    spec.subspec 'Dump' do |sp|
        sp.source_files = 'KBHTTP/Sources/Extensions/Dump/*.{swift}'
    end

    spec.subspec 'Alamofire' do |sp|
        sp.source_files = 'KBHTTP/Sources/Extensions/Alamofire/*.{swift}'

        sp.dependency 'KBHTTP/Core'
        sp.dependency 'KBHTTP/Dump'

        sp.dependency 'Alamofire', '~> 5.4.0'
    end

    spec.default_subspec = 'Core'    
    
end
