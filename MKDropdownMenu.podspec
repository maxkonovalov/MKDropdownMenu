Pod::Spec.new do |s|
  s.name             = "MKDropdownMenu"
  s.version          = "1.3.2"
  s.summary          = "Dropdown Menu for iOS"
  s.description      = <<-DESC
Dropdown Menu for iOS with many customizable parameters to suit any needs.
                       DESC

  s.homepage         = "https://github.com/maxkonovalov/MKDropdownMenu"
  s.screenshots      = "https://raw.github.com/maxkonovalov/MKDropdownMenu/master/Screenshots/MKDropdownMenu.png"
  s.license          = 'MIT'
  s.author           = "Max Konovalov"
  s.source           = { :git => "https://github.com/maxkonovalov/MKDropdownMenu.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'MKDropdownMenu/*'
end
