//
//  UserProfileCollectionViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 12/8/18.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class UserProfileCollectionViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: StickySplitCollectionViewFlowLayout!

    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(.userProfileHeader,
                                forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                withReuseIdentifier: .mainHeaderReuseIdentifier)
        collectionView.register(.squareCell,
                                forCellWithReuseIdentifier: .cellReuseIdentifier)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout.enforcedLayoutMode = .vertical
        collectionViewLayout.mainHeaderReferenceSize = CGSize(width: view.frame.width, height: .mainHeaderHeight)
        collectionViewLayout.mainHeaderMinimumReferenceSize = collectionViewLayout.mainHeaderReferenceSize
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            let newHeaderSize = CGSize(width: size.width,
                                       height: .mainHeaderHeight)
            self?.collectionViewLayout.mainHeaderReferenceSize = newHeaderSize
            self?.collectionViewLayout.mainHeaderMinimumReferenceSize = newHeaderSize
        }, completion: nil)
    }
    
    // MARK: - Private Properties
    
    private let quotes = [
        "Now, if you'll excuse me, there is some ravioli on the floor with only two footprints on it.",
        "Let's face it, we're in hot butter here. We should call Leela for help.",
        "This company's circling the drain, I tell you! I'd sell my shares right now for a sandwich.",
        "A complete sandwich? Ha! You got fleeced! I would have settled for a hard roll with ketchup inside.",
        "Okay, okay! I admit it! My people ate them all! We kept saying one more couldn't hurt, and then they were gone! We're sorry!"
    ]
    private let images = [
        UIImage(named: "beach"),
        UIImage(named: "nyc"),
        UIImage(named: "kayak"),
        UIImage(named: "rocks")
    ]
    private var sizingCell: StandardCollectionViewCell = { (nib: UINib) in
        guard let cell = nib.instantiate(withOwner: nil, options: nil).first as? StandardCollectionViewCell else {
            assertionFailure("failed to initialize view")
            return StandardCollectionViewCell()
        }
        return cell
    }(.squareCell)
    private weak var mainHeaderReusableView: UserProfileHeaderCollectionReusableView?
}

// MARK: - UICollectionViewDataSource

extension UserProfileCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .cellReuseIdentifier, for: indexPath)
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
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                       withReuseIdentifier: .mainHeaderReuseIdentifier,
                                                                       for: indexPath)
            mainHeaderReusableView = cell as? UserProfileHeaderCollectionReusableView
            return cell
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: .headerReuseIdentifier,
                                                                       for: indexPath)
            return cell
        default:
            assertionFailure("other kinds not implemented")
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileCollectionViewController: UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = min(collectionView.frame.width, collectionView.bounds.height)
        sizingCell.frame.size.width = width
        sizingCell.frame.size.height = collectionView.bounds.height
        sizingCell.primaryLabel?.text = "\(indexPath) - \(quotes[indexPath.item % quotes.count])"
        sizingCell.primaryLabel?.preferredMaxLayoutWidth = width
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        let height = sizingCell.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                        withHorizontalFittingPriority: .required,
                                                        verticalFittingPriority: .defaultLow).height
        return CGSize(width: width, height: height)
    }
}

// MARK: - UIScrollViewDelegate

extension UserProfileCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainHeaderReusableView?.parentScrolled(with: scrollView)
    }
}

// MARK: - Private Extensions

private extension String {
    static let cellReuseIdentifier = "cell"
    static let headerReuseIdentifier = "header"
    static let mainHeaderReuseIdentifier = "mainHeader"
}

private extension CGFloat {
    static let mainHeaderHeight: CGFloat = 200
}

private extension UINib {
    static let userProfileHeader = UINib(nibName: "\(UserProfileHeaderCollectionReusableView.self)", bundle: nil)
    static let squareCell = UINib(nibName: "SquareImageCollectionViewCell", bundle: nil)
}
