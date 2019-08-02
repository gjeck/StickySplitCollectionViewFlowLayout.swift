//
//  IntegrationTestCollectionViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 6/12/17.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class IntegrationTestCollectionViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewLayout: StickySplitCollectionViewFlowLayout!
    
    // MARK: - Public Properties
    let cellReuseIdentifier = "cell"
    let headerReuseIdentifier = "header"
    let footerReuseIdentifier = "footer"
    let mainHeaderReuseIdentifier = "mainHeader"
    let numberOfSections = 2
    let numberOfItemsPerSection = 10
    let quotes = [
        "Now, if you'll excuse me, there is some ravioli on the floor with only two footprints on it.",
        "Let's face it, we're in hot butter here. We should call Leela for help.",
        "This company's circling the drain, I tell you! I'd sell my shares right now for a sandwich.",
        "A complete sandwich? Ha! You got fleeced! I would have settled for a hard roll with ketchup inside.",
        "Okay, okay! I admit it! My people ate them all! We kept saying one more couldn't hurt, and then they were gone! We're sorry!"
    ]
    let images = [
        UIImage(named: "beach"),
        UIImage(named: "nyc"),
        UIImage(named: "kayak"),
        UIImage(named: "rocks")
    ]
    
    // MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(IntegrationTestCollectionViewController.parallaxReusableViewNib,
                                forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                withReuseIdentifier: mainHeaderReuseIdentifier)
        collectionView.register(IntegrationTestCollectionViewController.squareImageCollectionViewCellNib,
                                forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout.mainHeaderPinsToVisibleBounds = true
        collectionViewLayout.mainHeaderZPosition = .aboveAll
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = collectionView.adjustedContentInset.top
        } else {
            topInset = collectionView.contentInset.top
        }
        let width = min(view.frame.width, view.frame.height - topInset)
        collectionViewLayout.mainHeaderReferenceSize = CGSize(width: width, height: width)
        collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: width, height: 64)
        collectionViewLayout.itemSize.width = itemWidth
        if collectionViewLayout.scrollDirection == .horizontal &&
            (collectionViewLayout.layoutMode == .horizontal(.left) ||
                collectionViewLayout.layoutMode == .horizontal(.right)) {
            collectionViewLayout.itemSize.width = view.frame.width - width
            collectionViewLayout.itemSize.height = width
        }
        if collectionViewLayout.scrollDirection == .horizontal {
            collectionViewLayout.mainHeaderMinimumReferenceSize = CGSize(width: 64, height: width)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let animations: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.transition(to: size)
        }
        coordinator.animate(alongsideTransition: animations, completion: nil)
    }
    
    // MARK: - Public Methods
    public func transition(to size: CGSize) {
        let layoutMode = collectionViewLayout.layoutMode
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = collectionView.adjustedContentInset.top
        } else {
            topInset = collectionView.contentInset.top
        }
        let inset = layoutMode == .horizontal(.right) || layoutMode == .horizontal(.left) ? topInset : 0
        let width = min(size.width, size.height) - inset
        collectionViewLayout.mainHeaderReferenceSize = CGSize(width: width, height: width)
        collectionViewLayout.itemSize.width = itemWidth
    }
    
    // MARK: - Private Properties
    static private let bundle = Bundle(for: IntegrationTestCollectionViewController.self)
    static private let squareImageCollectionViewCellNib = UINib(nibName: "SquareImageCollectionViewCell", bundle: bundle)
    static private let parallaxReusableViewNib = UINib(nibName: "AvatarHeaderCollectionReusableView", bundle: bundle)
    
    private var sizingCell: StandardCollectionViewCell = { nib in
        if let cell = nib.instantiate(withOwner: nil, options: nil).first as? StandardCollectionViewCell {
            return cell
        }
        assertionFailure("SquareImageCollectionViewCell nib failed to load")
        return StandardCollectionViewCell()
    }(squareImageCollectionViewCellNib)
    
    private var itemWidth: CGFloat {
        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = collectionView.adjustedContentInset
        } else {
            contentInset = collectionView.contentInset
        }
        var horizontalMax = collectionView.frame.width - contentInset.left - contentInset.right
        if collectionViewLayout.scrollDirection == .horizontal &&
            (collectionViewLayout.layoutMode == .horizontal(.left) || collectionViewLayout.layoutMode == .horizontal(.right)) {
            horizontalMax -= collectionViewLayout.mainHeaderReferenceSize.width
        }
        let verticalMax = collectionView.frame.height - contentInset.top - contentInset.bottom
        return min(horizontalMax, verticalMax)
    }
}

// MARK: - UICollectionViewDataSource
extension IntegrationTestCollectionViewController: UICollectionViewDataSource {
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
            standardCell.primaryLabel?.text = "\(indexPath) - \(quotes[indexPath.item % quotes.count])"
            standardCell.primaryImageView?.image = images[indexPath.item % images.count]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                       withReuseIdentifier: footerReuseIdentifier,
                                                                       for: indexPath)
            if let standardCell = cell as? StandardCollectionReusableView {
                standardCell.label?.text = "\(kind) \(indexPath)"
            }
            return cell
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                       withReuseIdentifier: mainHeaderReuseIdentifier,
                                                                       for: indexPath)
            return cell
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

// MARK: - UICollectionViewDelegateFlowLayout
extension IntegrationTestCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizingCell.frame.size.width = itemWidth
        sizingCell.frame.size.height = collectionView.bounds.height
        sizingCell.primaryLabel?.text = "\(indexPath) - \(quotes[indexPath.item % quotes.count])"
        sizingCell.primaryLabel?.preferredMaxLayoutWidth = itemWidth
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        var height = sizingCell.systemLayoutSizeFitting(CGSize(width: itemWidth, height: 0),
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .defaultLow).height
        if self.collectionViewLayout.scrollDirection == .horizontal &&
            (self.collectionViewLayout.layoutMode == .horizontal(.left) ||
                self.collectionViewLayout.layoutMode == .horizontal(.right)) {
            let contentInset: UIEdgeInsets
            if #available(iOS 11.0, *) {
                contentInset = collectionView.adjustedContentInset
            } else {
                contentInset = collectionView.contentInset
            }
            height = collectionView.frame.height - contentInset.top - contentInset.bottom
        }
        return CGSize(width: itemWidth, height: height)
    }
    
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
