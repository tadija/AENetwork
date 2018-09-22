Pod::Spec.new do |s|

s.name = 'AENetwork'
s.summary = 'Swift minion for simple and lightweight networking'
s.version = '0.7.4'
s.license = { :type => 'MIT', :file => 'LICENSE' }

s.source = { :git => 'https://github.com/tadija/AENetwork.git', :tag => s.version }
s.source_files = 'Sources/*.swift'

s.swift_version = '4.2'

s.ios.deployment_target = '9.0'

s.homepage = 'https://github.com/tadija/AENetwork'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

end
