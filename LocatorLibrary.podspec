Pod::Spec.new do |s|

  # 1
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = 'LocatorLibrary'
  s.summary = 'Locator lib a user select an branch.'
  s.requires_arc = true

  # 2
  s.version = '0.1.0'

  # 3
  s.license = 'No License'

  # 4 - Replace with your name and e-mail address
  s.author = { 'Pod Spec' => 'vinay.shivanna@photoninfotech.net'}

  # 5 - Replace this URL with your own Github page's URL (from the address bar)
  s.homepage = 'https://github.com/vinayshi/Locator'

  # 6 - Replace this URL with your own Git URL from "Quick Setup"
  s.source = { :git => 'https://github.com/vinayshi/Locator.git', :tag => '0.0.0'}

  # 8
  s.source_files = 'LocatorLibrary/**/*.{swift}'

  # 9
  s.resources = 'LocatorLibrary/**/*.{png,jpeg,jpg,storyboard,xib,.plist}'
end