Pod::Spec.new do |s|
  s.name             = 'JXSQLiteManager'
  s.version          = '0.1.1'
  s.summary          = '对 SQLite.swift 的模型封装'
  
  s.description      = <<-DESC
  对SQLite.swift的封装，使用swift的反射原理，Model直接存储.获取. 无需再转换,增删改查. 脱离sql语句,不需要添加相关的绑定操作，直接完成转换。
                       DESC

  s.homepage         = 'https://github.com/jeromexiong/SQLiteManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jerome Xiong' => 'jeromexxc@gmail.com' }
  s.source           = { :git => 'https://github.com/jeromexiong/SQLiteManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.source_files = 'SQLiteManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SQLiteManager' => ['SQLiteManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SQLite.swift', '~> 0.12.2'
end
