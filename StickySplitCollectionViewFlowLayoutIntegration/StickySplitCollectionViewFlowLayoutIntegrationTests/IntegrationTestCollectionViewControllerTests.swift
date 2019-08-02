//
//  IntegrationTestCollectionViewControllerTests.swift
//  StickySplitCollectionViewFlowLayoutIntegrationTests
//
//  Created by Greg Jeckell on 10/7/18.
//

import XCTest
import FBSnapshotTestCase
@testable import StickySplitCollectionViewFlowLayoutIntegration

class IntegrationTestCollectionViewControllerTests: FBSnapshotTestCase {
    var viewController: IntegrationTestCollectionViewController!
    var navigationController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "\(IntegrationTestCollectionViewController.self)", bundle: nil)
        viewController = storyboard.instantiateInitialViewController() as? IntegrationTestCollectionViewController
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
                                                    at: .centeredVertically,
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
                                                    at: .centeredVertically,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalUnstickyHeaders() {
        viewController.collectionViewLayout.mainHeaderReferenceSize = CGSize(width: 100, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: 64, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalScrolledUnstickyHeader() {
        viewController.collectionViewLayout.mainHeaderReferenceSize = CGSize(width: 100, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: 64, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .centeredHorizontally,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testPortraitHorizontalStickyHeaders() {
        viewController.collectionViewLayout.mainHeaderReferenceSize = CGSize(width: 100, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: 64, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        FBSnapshotVerifyView(viewController.view)
    }
    
    func testPortraitHorizontalScrolledStickyHeader() {
        viewController.collectionViewLayout.mainHeaderReferenceSize = CGSize(width: 100, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: 64, height: viewController.collectionView.frame.height)
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .horizontal
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .centeredHorizontally,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeInitialLayoutUnstickyHeaders() {
        viewController.transition(to: navigationController.view.frame.size)
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeScrolledUnstickyHeader() {
        viewController.transition(to: navigationController.view.frame.size)
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = false
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .centeredVertically,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeInitialLayoutStickyHeaders() {
        viewController.transition(to: navigationController.view.frame.size)
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        FBSnapshotVerifyView(navigationController.view)
    }
    
    func testLandscapeScrolledStickyHeader() {
        viewController.transition(to: navigationController.view.frame.size)
        navigationController.rotate()
        viewController.collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        viewController.collectionViewLayout.scrollDirection = .vertical
        let path = IndexPath(item: viewController.numberOfItemsPerSection - 1,
                             section: viewController.numberOfSections - 1)
        viewController.collectionView?.scrollToItem(at: path,
                                                    at: .centeredVertically,
                                                    animated: false)
        FBSnapshotVerifyView(navigationController.view)
    }
}
