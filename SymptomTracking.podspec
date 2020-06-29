#
# Be sure to run `pod lib lint SymptomTracking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SymptomTracking'
  s.version          = '0.3.0'
  s.summary          = 'A short description of SymptomTracking.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jdkizer9/SymptomTracking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jdkizer9' => 'james@curiosityhealth.com' }
  s.source           = { :git => 'https://github.com/jdkizer9/SymptomTracking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'SymptomTracking/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SymptomTracking' => ['SymptomTracking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'Gloss', '~> 2.0'
  s.dependency 'LS2SDK', '~> 0.10'
  s.dependency 'ResearchKit', '~> 1.5'
  s.dependency 'ResearchSuiteExtensions', '~> 0.25'
  s.dependency 'ResearchSuiteTaskBuilder', '~> 0.13'
  s.dependency 'ResearchSuiteResultsProcessor', '~> 0.9'
  s.dependency 'ResearchSuiteApplicationFramework', '~> 0.25'
  s.dependency 'SnapKit', '~> 4.0'

end
