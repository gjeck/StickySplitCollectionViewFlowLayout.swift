//
//  StickySplitCollectionViewFlowLayoutTests.swift
//  StickySplitCollectionViewFlowLayoutTests
//
//  Created by Greg Jeckell on 6/5/17.
//

import XCTest
@testable import StickySplitCollectionViewFlowLayout

class StickySplitCollectionViewFlowLayoutTests: XCTestCase {
    var layout: StickySplitCollectionViewFlowLayout!
    var collectionViewController: UICollectionViewController!
    var mockDataSource: MockCollectionViewDataSource!
    
    override func setUp() {
        super.setUp()
        layout = StickySplitCollectionViewFlowLayout()
        collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        mockDataSource = MockCollectionViewDataSource()
        collectionViewController.collectionView?.register(UICollectionViewCell.self,
                                                          forCellWithReuseIdentifier: mockDataSource.cellReuseIdentifier)
        collectionViewController.collectionView?.register(UICollectionReusableView.self,
                                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                          withReuseIdentifier: mockDataSource.headerReuseIdentifier)
        collectionViewController.collectionView?.register(UICollectionReusableView.self,
                                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                          withReuseIdentifier: mockDataSource.footerReuseIdentifier)
        collectionViewController.collectionView?.register(UICollectionReusableView.self,
                                                          forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                          withReuseIdentifier: mockDataSource.mainHeaderReuseIdentifier)
        collectionViewController.collectionView?.dataSource = mockDataSource
        collectionViewController.beginAppearanceTransition(true, animated: false)
        collectionViewController.endAppearanceTransition()
        collectionViewController.view.frame = CGRect(x: 0, y: 0, width: 375.0, height: 667.0)
        collectionViewController.collectionView?.layoutSubviews()
    }
    
    override func tearDown() {
        super.tearDown()
        mockDataSource = nil
        collectionViewController = nil
        layout = nil
    }
    
    func testItHasZeroContentSizeIfNoSuperview() {
        let collectionView = collectionViewController.collectionView
        collectionView?.removeFromSuperview()
        XCTAssertEqual(layout.collectionViewContentSize, .zero)
    }
    
    func testVerticalLayoutModeIsValid() {
        XCTAssertEqual(layout.layoutMode, .vertical)
    }
    
    func testHorizontalLayoutModeIsValid() {
        let width = collectionViewController.view.frame.width
        collectionViewController.collectionView?.frame = CGRect(x: 0,
                                                                y: 0,
                                                                width: width,
                                                                height: width - width / 2.0)
        XCTAssertEqual(layout.layoutMode, .horizontal(.left))
    }
    
    func testContentSizeIsCorrectlyCalculatedForVerticalLayoutMode() {
        let itemHeight: CGFloat = 100
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let itemSize = CGSize(width: collectionViewController.view.frame.width, height: itemHeight)
        layout.itemSize = itemSize
        layout.mainHeaderReferenceSize = itemSize
        
        let expectedSize = CGSize(width: collectionViewController.view.frame.width,
                                  height: itemHeight * CGFloat(mockDataSource.numberOfItemsPerSection) + layout.mainHeaderReferenceSize.height)
        XCTAssertEqual(layout.collectionViewContentSize, expectedSize)
    }
    
    func testContentSizeIsCorrectlyCalculatedForHorizontalLayoutMode() {
        let itemHeight: CGFloat = 100
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let itemSize = CGSize(width: collectionViewController.view.frame.width, height: itemHeight)
        layout.itemSize = itemSize
        layout.mainHeaderReferenceSize = itemSize
        layout.enforcedLayoutMode = .horizontal(.left)
        
        let expectedSize = CGSize(width: collectionViewController.view.frame.width,
                                  height: itemHeight * CGFloat(mockDataSource.numberOfItemsPerSection))
        XCTAssertEqual(layout.collectionViewContentSize, expectedSize)
    }
    
    func testItReturnsNilWhenReferenceSizeForHeaderIsZero() {
        layout.headerReferenceSize = .zero
        layout.invalidateLayout()
        collectionViewController.collectionView?.layoutSubviews()
        let attributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     at: IndexPath(item: 0, section: 0))
        XCTAssertNil(attributes)
    }
    
    func testItReturnsNilWhenReferenceSizeForFooterIsZero() {
        layout.footerReferenceSize = .zero
        layout.invalidateLayout()
        collectionViewController.collectionView?.layoutSubviews()
        let attributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     at: IndexPath(item: 0, section: 0))
        XCTAssertNil(attributes)
    }
    
    func testItReturnsNilWhenMainHeaderReferenceSizeIsZero() {
        layout.mainHeaderReferenceSize = .zero
        let attributes = layout.layoutAttributesForSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                     at: IndexPath(item: 0, section: 0))
        XCTAssertNil(attributes)
    }
    
    func testMainHeaderLayoutIsCorrectInCollectionView() {
        layout.mainHeaderReferenceSize = CGSize(width: collectionViewController.view.frame.width, height: 100)
        let attributes = layout.layoutAttributesForSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                     at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 0, width: collectionViewController.view.frame.width, height: 100))
    }
}

// MARK: - Mocks
class MockCollectionViewDataSource: NSObject {
    var numberOfSections = 1
    var numberOfItemsPerSection = 10
    var cellReuseIdentifier = "cell"
    var headerReuseIdentifier = "header"
    var footerReuseIdentifier = "footer"
    var mainHeaderReuseIdentifier = "mainHeader"
}

extension MockCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsPerSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                      for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: headerReuseIdentifier,
                                                                       for: indexPath)
            return view
        case UICollectionView.elementKindSectionFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: footerReuseIdentifier,
                                                                       for: indexPath)
            return view
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: mainHeaderReuseIdentifier,
                                                                       for: indexPath)
            return view
        default:
            assertionFailure("other kinds not implemented")
            return UICollectionReusableView()
        }
    }
}
