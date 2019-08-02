//
//  NoMainHeaderCollectionViewControllerTests.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 6/5/17.
//

import XCTest
import FBSnapshotTestCase
@testable import StickySplitCollectionViewFlowLayoutIntegration

class NoMainHeaderCollectionViewControllerTests: FBSnapshotTestCase {
    var viewController: NoMainHeaderCollectionViewController!
    var navigationController: UINavigationController!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "\(NoMainHeaderCollectionViewController.self)", bundle: nil)
        viewController = storyboard.instantiateInitialViewController() as? NoMainHeaderCollectionViewController
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.loadViewIfNeeded()
        navigationController.view.frame = CGRect(x: 0, y: 0, width: 375.0, height: 667.0)
        navigationController.view.setNeedsLayout()
        navigationController.view.layoutIfNeeded()
        viewController.viewDidLoad()
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        viewController.view.frame = navigationController.view.frame
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        recordMode = false
    }
    
    override func tearDown() {
        super.tearDown()
        viewController = nil
        navigationController = nil
    }
    
    func testPortraitInitialLayoutUnstickyHeaders() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitScrolledUnstickyHeader() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .top,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitInitialLayoutStickyHeaders() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitScrolledStickyHeader() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .top,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalUnstickyHeaders() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalScrolledUnstickyHeader() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .right,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalStickyHeaders() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(viewController.view)
    }
    
    func testPortraitHorizontalScrolledStickyHeader() {
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .right,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeInitialLayoutUnstickyHeaders() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeScrolledUnstickyHeader() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .top,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeInitialLayoutStickyHeaders() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeScrolledStickyHeader() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .bottom,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeHorizontalUnstickyHeaders() {
        navigationController.rotate()
        self.viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        self.viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeHorizontalScrolledUnstickyHeader() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .right,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeHorizontalStickyHeaders() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeHorizontalScrolledStickyHeader() {
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .right,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
}

extension UIViewController {
    func rotate() {
        view.frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
