//
//  UserProfileHeaderCollectionReusableView.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 12/8/18.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class UserProfileHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Public Properties
    
    let user = Story(name: "", imageName: "poop")
    
    let stories: [Story] = [
        Story(name: "sweet", imageName: "rocks"),
        Story(name: "cool", imageName: "kayak"),
        Story(name: "wow", imageName: "nyc"),
        Story(name: "rad", imageName: "beach")
    ]
    
    // MARK: - IBOutlets
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: StickySplitCollectionViewFlowLayout!
    @IBOutlet private var refreshIndicator: UIActivityIndicatorView!
    
    // MARK: - UICollectionReusableView Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }
    
    // MARK: - Public Methods
    
    func parentScrolled(with scrollView: UIScrollView) {
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = scrollView.adjustedContentInset.top
        } else {
            topInset = scrollView.contentInset.top
        }
        let y = scrollView.contentOffset.y + topInset
        if !refreshIndicator.isAnimating {
            refreshIndicator.transform = refreshIndicator.transform.rotated(by: y * -0.0007)
        }
        if y < -65 {
            refreshIndicator.startAnimating()
        }else if y >= 0 {
            refreshIndicator.stopAnimating()
        }
    }
    
    // MARK: - Private Methods
    
    private func registerCells() {
        collectionView.register(.init(nibName: .headerNibName, bundle: nil),
                                forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                withReuseIdentifier: .headerReuseIdentifier )
        collectionView.register(.init(nibName: .cellNibName, bundle: nil),
                                forCellWithReuseIdentifier: .cellReuseIdentifier)
        collectionViewLayout.mainHeaderReferenceSize = .init(width: 90, height: collectionView.frame.height)
        collectionViewLayout.mainHeaderMinimumReferenceSize = collectionViewLayout.mainHeaderReferenceSize
        collectionView.contentInset.left = 10
    }
}

extension UserProfileHeaderCollectionReusableView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .cellReuseIdentifier, for: indexPath)
        if let standardCell = cell as? StandardCollectionViewCell {
            standardCell.primaryImageView?.image = UIImage(named: stories[indexPath.item % stories.count].imageName)
            standardCell.primaryLabel?.text = stories[indexPath.item % stories.count].name
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                       withReuseIdentifier: .headerReuseIdentifier,
                                                                       for: indexPath)
            if let standardCell = cell as? StandardCollectionViewCell {
                standardCell.primaryImageView?.image = UIImage(named: user.imageName)
                standardCell.primaryImageView?.layer.cornerRadius = cell.frame.width / 2.0
            }
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

extension UserProfileHeaderCollectionReusableView: UICollectionViewDelegateFlowLayout {
    
}

private extension String {
    static let cellNibName = "UserProfileStoryCollectionViewCell"
    static let cellReuseIdentifier = "cell"
    static let headerNibName = "UserProfileAvatarCollectionViewCell"
    static let headerReuseIdentifier = "header"
}
