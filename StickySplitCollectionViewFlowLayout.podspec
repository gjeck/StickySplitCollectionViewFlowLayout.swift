Pod::Spec.new do |s|
    s.name = "StickySplitCollectionViewFlowLayout"
    s.version = "0.0.22"
    s.summary = "StickySplitCollectionViewFlowLayout is a special collection view layout."
    s.homepage = "https://github.com/gjeck/StickySplitCollectionViewFlowLayout.swift"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "Gregory Jeckell" => "gjeck" }
    s.platform = :ios, "9.0"
    s.swift_version = "4"
    s.requires_arc = true
    s.frameworks = "UIKit"
    s.source = { :git => "https://gjeckell@bitbucket.savagebeast.com/scm/~gjeckell/stickysplitcollectionviewflowlayout.git", :tag => "#{s.version}" }
    s.source_files  = "StickySplitCollectionViewFlowLayout/StickySplitCollectionViewFlowLayout/**/*.{swift,h}"
    s.description  = <<-DESC
        StickySplitCollectionViewFlowLayout is a collection view layout derived from UICollectionViewFlowLayout. It supports the feature set of a flow layout plus some nice additions.
    DESC
end