//
//  ParallaxCollectionViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 6/6/17.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class ParallaxCollectionViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: StickySplitCollectionViewFlowLayout!
    
    // MARK: - Public Properties
    let cellReuseIdentifier = "cell"
    let headerReuseIdentifier = "header"
    let mainHeaderReuseIdentifier = "mainHeader"
    let numberOfSections = 2
    let numberOfItemsPerSection = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ParallaxHeaderCollectionReusableView", bundle: nil)
        collectionView.register(nib,
                                forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                withReuseIdentifier: mainHeaderReuseIdentifier)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewLayout.itemSize.width = itemWidth(forSize: collectionView.frame.size)
        let width = min(collectionView.frame.width, collectionView.frame.height - collectionView.contentInset.top)
        collectionViewLayout.mainHeaderReferenceSize = CGSize(width: width, height: width)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let animations: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.collectionViewLayout.invalidateLayout()
            strongSelf.collectionViewLayout.itemSize.width = strongSelf.itemWidth(forSize: size)
        }
        coordinator.animate(alongsideTransition: animations, completion: nil)
    }
    
    private func itemWidth(forSize size: CGSize) -> CGFloat {
        return size.width > size.height ? size.width - collectionViewLayout.mainHeaderReferenceSize.width : size.width
    }
}

extension ParallaxCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsPerSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                       withReuseIdentifier: mainHeaderReuseIdentifier,
                                                                       for: indexPath)
            return cell
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: headerReuseIdentifier,
                                                                       for: indexPath)
            if let standardCell = cell as? StandardCollectionReusableView {
                standardCell.label?.text = "\(kind) \(indexPath)"
            }
            return cell
        default:
            assertionFailure("other kinds not implemented")
            return UICollectionReusableView()
        }
    }
}

extension ParallaxCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
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
