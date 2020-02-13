Pod::Spec.new do |spec|
    spec.name      = 'AlamofireMock'
    spec.version   = '1.0.0'
    spec.license   = 'MIT'
    spec.summary   = 'Extension to Alamofire that makes mocking easy.'
    spec.homepage  = 'https://github.com/moros/AlamofireMock'
    spec.author    = { "Doug Mason" => "androidsoong@gmail.com" }
    spec.source    = { :git => "https://github.com/moros/AlamofireMock.git", :tag => spec.version.to_s }
    
    spec.ios.deployment_target      = '10.0'
    spec.osx.deployment_target      = '10.12'
    spec.tvos.deployment_target     = '10.0'
    
    spec.swift_versions = ['5.0', '5.1']
    spec.source_files   = 'Sources/**/*.swift'
    spec.dependency 'Alamofire', '~> 4.9.0'
    spec.dependency 'SwiftyJSON', '~> 5.0.0'
    spec.dependency 'AlamofireExtended', '~> 1.0.5'
end
