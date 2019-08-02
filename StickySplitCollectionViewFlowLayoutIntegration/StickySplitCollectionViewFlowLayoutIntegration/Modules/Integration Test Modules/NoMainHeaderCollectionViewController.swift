//
//  NoMainHeaderCollectionViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 6/5/17.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class NoMainHeaderCollectionViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewLayout: StickySplitCollectionViewFlowLayout!
    
    // MARK: - Public Properties
    let cellReuseIdentifier = "cell"
    let headerReuseIdentifier = "header"
    let numberOfSections = 2
    let numberOfItemsPerSection = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .blue
        collectionView.addSubview(refreshControl)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let animations: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.collectionViewLayout.invalidateLayout()
        }
        coordinator.animate(alongsideTransition: animations, completion: nil)
    }
}

extension NoMainHeaderCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsPerSection
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                      for: indexPath)
        if let standardCell = cell as? StandardCollectionViewCell {
            standardCell.primaryLabel?.text = "\(indexPath)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            fallthrough
        default:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: headerReuseIdentifier,
                                                                       for: indexPath)
            if let standardCell = cell as? StandardCollectionReusableView {
                standardCell.label?.text = "\(kind) \(indexPath)"
            }
            return cell
        }
    }
}

extension NoMainHeaderCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        // iOS 11 specific hack see:
        // https://stackoverflow.com/questions/45215932/uicollectionview-showing-scroll-indicator-for-every-section-header-zindex-broke?noredirect=1&lq=1
        if #available(iOS 11, *) {
            if (elementKind == UICollectionView.elementKindSectionHeader) {
                view.layer.zPosition = 0
            }
        }
    }
}
