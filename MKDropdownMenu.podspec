#
# Be sure to run `pod lib lint MKDropdownMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MKDropdownMenu"
  s.version          = "1.0"
  s.summary          = "Dropdown Menu for iOS"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Dropdown Menu for iOS with many customizable parameters to suit any needs.
                       DESC

  s.homepage         = "https://github.com/maxkonovalov/MKDropdownMenu"
# s.screenshots      = "https://github.com/maxkonovalov/MKDropdownMenu/master/Screenshots/MKDropdownMenu.png"
  s.license          = 'MIT'
  s.author           = "Max Konovalov"
  s.source           = { :git => "https://github.com/maxkonovalov/MKDropdownMenu.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'MKDropdownMenu/**/*'
# s.resource_bundles = {
#    'MKDropdownMenu' => ['Pod/Assets/*.png']
# }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
