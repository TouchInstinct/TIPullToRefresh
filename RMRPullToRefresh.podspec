Pod::Spec.new do |spec|
  spec.name         = "RMRPullToRefresh"
  spec.version      = "0.8.0"
  spec.platform     = :ios, "9.0"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.summary      = "A pull to refresh control for UIScrollView (UITableView and UICollectionView)"
  spec.homepage     = "http://redmadrobot.com/"
  spec.author       = "Ilya Merkulov"
  spec.source       = { :git => "https://git.redmadrobot.com/helper-ios/RMRPullToRefresh.git", :tag => spec.version }
  spec.source_files = "Classes/*.{swift}", "Classes/Default/*.{swift}"
  spec.resources    = ['Images/*.png']
end