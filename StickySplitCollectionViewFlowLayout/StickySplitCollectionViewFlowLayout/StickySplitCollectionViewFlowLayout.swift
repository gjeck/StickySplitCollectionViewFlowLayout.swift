//
//  StickySplitCollectionViewFlowLayout.swift
//  GJUserInterface
//
//  Created by Greg Jeckell on 5/23/17.
//

import UIKit

open class StickySplitCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Public Properties
    
    /**
     The size for the main header. Will not be part of the layout if the size is equal to `CGSize.zero`.
     
     Defaults to `CGSize.zero`
    */
    open var mainHeaderReferenceSize: CGSize = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    /**
     The minimum size for the main header.
     
     Defaults to `CGSize.zero`
    */
    open var mainHeaderMinimumReferenceSize: CGSize = .zero
    
    /**
     The maximum size for the main header.
 
     Defaults to `CGSize(width: .max, height: .max)`
    */
    open var mainHeaderMaximumReferenceSize: CGSize = .init(width: .max, height: .max)
    
    /**
     Indicates whether the main header will remain fixed to the collection view bounds.
     
     Defaults to `false`
     */
    open var mainHeaderPinsToVisibleBounds = false
    
    /**
     Indicates the z-position, or layering behavior, of the main header.
     
     Defaults to `MainHeaderZPositionMode.belowAll`
     */
    open var mainHeaderZPosition: MainHeaderZPositionMode = .belowAll
    
    /**
     The evaluated layout mode. Determines if the layout utilizes the horizontal or vertical layout modes.
    */
    open var layoutMode: LayoutMode {
        guard let collectionView = collectionView else {
            return .vertical
        }
        switch enforcedLayoutMode {
        case .implicit(let horizontalMode):
            let bounds = collectionView.bounds
            return bounds.width > bounds.height ? .horizontal(horizontalMode) : .vertical
        case .horizontal(_), .vertical:
            return enforcedLayoutMode
        }
    }
    
    /**
     A layout mode override. When equal to `LayoutMode.implicit` the layout mode is determined by the bounds of the collection view.
     
     Defaults to `.implicit(.left)`
    */
    open var enforcedLayoutMode: LayoutMode = .implicit(.left) {
        didSet {
            invalidateLayout()
        }
    }
    
    /**
     The element kind defining the supplementary view for the main header.
    */
    public static let mainElementKind: String = "StickySplitCollectionViewFlowLayoutMainHeader"
    
    // MARK: - UICollectionViewFlowLayout Overrides
    
    /**
     A Boolean value indicating whether headers pin to the top of the collection view bounds during scrolling.
     
     When this property is `true`, section header views scroll with content until they reach the top of the screen
     or the main header, at which point they are pinned to the upper bounds of the collection view. Each new header
     view that scrolls to the top of the screen or main header pushes the previously pinned header view offscreen.
     
     Defaults to `false`.
    */
    open override var sectionHeadersPinToVisibleBounds: Bool {
        get { return false }
        set { isStickyHeadersEnabled = newValue }
    }
    
    /**
     A Boolean value indicating whether footers pin to the bottom of the collection view bounds during scrolling.
     
     When this property is `true`, section footer views scroll with content until they reach the bottom of the screen,
     at which point they are pinned to the lower bounds of the collection view. Each new footer view that scrolls 
     to the bottom of the screen pushes the previously pinned footer view offscreen.
     
     Defaults to `false`.
    */
    open override var sectionFootersPinToVisibleBounds: Bool {
        get { return false }
        set { isStickyFootersEnabled = newValue }
    }
    
    open override func prepare() {
        guard let collectionView = collectionView else {
            super.prepare()
            return
        }
        let collectionViewInset: UIEdgeInsets
        if let initialInset = initialInset {
            collectionViewInset = initialInset
        } else if #available(iOS 11.0, *) {
            collectionViewInset = collectionView.adjustedContentInset
        } else {
            collectionViewInset = collectionView.contentInset
        }
        if initialInset == nil {
            initialInset = collectionViewInset
        }
        switch layoutMode {
        case .horizontal(mode: .left):
            collectionView.contentInset.left = scrollDirection == .vertical ? mainHeaderReferenceSize.width : collectionViewInset.left
            collectionView.contentInset.right = collectionViewInset.right
        case .horizontal(mode: .right):
            collectionView.contentInset.left = collectionViewInset.left
            collectionView.contentInset.right = scrollDirection == .vertical ? mainHeaderReferenceSize.width : collectionViewInset.right
            collectionView.scrollIndicatorInsets.left = collectionViewInset.left
            collectionView.scrollIndicatorInsets.right = scrollDirection == .vertical ? mainHeaderReferenceSize.width : collectionViewInset.right
        case .vertical:
            collectionView.contentInset.left = collectionViewInset.left
            collectionView.contentInset.right = collectionViewInset.right
            collectionView.scrollIndicatorInsets.left = collectionViewInset.left
            collectionView.scrollIndicatorInsets.right = collectionViewInset.right
        case .implicit(_):
            assertionFailure("invalid layout mode")
            break
        }
        super.prepare()
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                            at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
        
        let dx = scrollDirection == .vertical ? 0 : mainHeaderReferenceSize.width
        let dy = scrollDirection == .vertical ? mainHeaderReferenceSize.height : 0
        
        let collectionViewInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            collectionViewInset = collectionView.adjustedContentInset
        } else {
            collectionViewInset = collectionView.contentInset
        }
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath),
               referenceSizeForHeader(inSection: indexPath.section) != .zero else {
                return nil
            }
            
            switch layoutMode {
            case .horizontal(_):
                if !isStickyHeadersEnabled {
                    let frame = attributes.frame.offsetBy(dx: dx, dy: 0)
                    attributes.frame = frame
                    return attributes
                }
                
                var nextHeaderOrigin = CGPoint(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)
                
                if indexPath.section + 1 < collectionView.numberOfSections,
                    let nextHeaderAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                                                          at: IndexPath(item: 0, section: indexPath.section + 1)) {
                    let adjustedNextHeader = nextHeaderAttributes.frame.offsetBy(dx: dx, dy: 0)
                    nextHeaderOrigin = adjustedNextHeader.origin
                }
                
                var frame = attributes.frame.offsetBy(dx: dx, dy: 0)
                let footerSize = referenceSizeForFooter(inSection: indexPath.section)
                
                if scrollDirection == .vertical {
                    let offsetAdjustment = collectionView.contentOffset.y + collectionViewInset.top
                    let nexHeaderOffset = nextHeaderOrigin.y - frame.size.height - footerSize.height
                    frame.origin.y = min(max(offsetAdjustment, frame.origin.y), nexHeaderOffset)
                } else { // scrollDirection == .horizontal
                    let nextHeaderOffset = nextHeaderOrigin.x - frame.size.width - footerSize.width
                    if mainHeaderPinsToVisibleBounds && mainHeaderZPosition == .aboveAll {
                        let offsetAdjustment = mainHeaderMinimumReferenceSize.width + collectionView.contentOffset.x + collectionViewInset.left
                        frame.origin.x = min(max(offsetAdjustment, frame.origin.x), nextHeaderOffset)
                    } else {
                        let offsetAdjustment = collectionView.contentOffset.x + collectionViewInset.left
                        frame.origin.x = min(max(offsetAdjustment, frame.origin.x), nextHeaderOffset)
                    }
                }
                
                attributes.frame = frame
            case .vertical:
                if !isStickyHeadersEnabled {
                    let frame = attributes.frame.offsetBy(dx: dx, dy: dy)
                    attributes.frame = frame
                    return attributes
                }
                
                var nextHeaderOrigin = CGPoint(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)
                
                if indexPath.section + 1 < collectionView.numberOfSections,
                    let nextHeaderAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                                                          at: IndexPath(item: 0, section: indexPath.section + 1)) {
                    let adjustedNextHeader = nextHeaderAttributes.frame.offsetBy(dx: dx, dy: dy)
                    nextHeaderOrigin = adjustedNextHeader.origin
                }
                
                let footerSize = referenceSizeForFooter(inSection: indexPath.section)
                var frame = attributes.frame.offsetBy(dx: dx, dy: dy)
                
                if scrollDirection == .vertical {
                    let nextHeaderOffset = nextHeaderOrigin.y - frame.size.height - footerSize.height
                    if mainHeaderPinsToVisibleBounds && mainHeaderZPosition == .aboveAll {
                        let offsetAdjustment = mainHeaderMinimumReferenceSize.height + collectionView.contentOffset.y + collectionViewInset.top
                        frame.origin.y = min(max(offsetAdjustment, frame.origin.y), nextHeaderOffset)
                    } else {
                        let offsetAdjustment = collectionView.contentOffset.y + collectionViewInset.top
                        frame.origin.y = min(max(offsetAdjustment, frame.origin.y), nextHeaderOffset)
                    }
                } else { // scrollDirection == .horizontal
                    let nextHeaderOffset = nextHeaderOrigin.x - frame.size.width - footerSize.width
                    if mainHeaderPinsToVisibleBounds && mainHeaderZPosition == .aboveAll  {
                        let offsetAdjustment = mainHeaderMinimumReferenceSize.width + collectionView.contentOffset.x + collectionViewInset.left
                        frame.origin.x = min(max(offsetAdjustment, frame.origin.x), nextHeaderOffset)
                    } else {
                        let offsetAdjustment = collectionView.contentOffset.x + collectionViewInset.left
                        frame.origin.x = min(max(offsetAdjustment, frame.origin.x), nextHeaderOffset)
                    }
                }
                
                attributes.frame = frame
            case .implicit(_):
                assertionFailure("invalid layout mode")
                break
            }

            attributes.zIndex = StickySplitCollectionViewFlowLayout.headerFooterZIndex
            return attributes
        case UICollectionView.elementKindSectionFooter:
            guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath),
                referenceSizeForFooter(inSection: indexPath.section) != .zero else {
                return nil
            }
            
            switch layoutMode {
            case .horizontal(_):
                if !isStickyFootersEnabled {
                    let frame = attributes.frame.offsetBy(dx: dx, dy: 0)
                    attributes.frame = frame
                    return attributes
                }
                
                var previousFooterOrigin = CGPoint(x: -CGFloat.greatestFiniteMagnitude, y: -CGFloat.greatestFiniteMagnitude)
                
                if indexPath.section - 1 >= 0,
                    let previousFooterAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                                                              at: IndexPath(item: 0, section: indexPath.section - 1)) {
                    let adjustedPreviousFooter = previousFooterAttributes.frame.offsetBy(dx: dx, dy: 0)
                    previousFooterOrigin = adjustedPreviousFooter.origin
                }
                
                var frame = attributes.frame.offsetBy(dx: dx, dy: 0)
                let headerSize = referenceSizeForHeader(inSection: indexPath.section)
                
                if scrollDirection == .vertical {
                    let offsetAdjustment = collectionView.bounds.origin.y + collectionView.bounds.height - frame.height
                    let previousFooterOffset = previousFooterOrigin.y + frame.size.height + headerSize.height
                    frame.origin.y = max(min(offsetAdjustment, frame.origin.y), previousFooterOffset)
                } else { // scrollDirection == .horizontal
                    let previousFooterOffset = previousFooterOrigin.x + frame.size.width + headerSize.width
                    let offsetAdjustment = collectionView.bounds.origin.x + collectionView.bounds.width - frame.width
                    frame.origin.x = max(min(offsetAdjustment, frame.origin.x), previousFooterOffset)
                }
                
                attributes.frame = frame
            case .vertical:
                if !isStickyFootersEnabled {
                    let frame = attributes.frame.offsetBy(dx: dx, dy: dy)
                    attributes.frame = frame
                    return attributes
                }
                
                var previousFooterOrigin = CGPoint(x: -CGFloat.greatestFiniteMagnitude, y: -CGFloat.greatestFiniteMagnitude)
                
                if indexPath.section - 1 >= 0,
                    let previousFooterAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                                                              at: IndexPath(item: 0, section: indexPath.section - 1)) {
                    let adjustedPreviousFooter = previousFooterAttributes.frame.offsetBy(dx: dx, dy: dy)
                    previousFooterOrigin = adjustedPreviousFooter.origin
                }
                
                var frame = attributes.frame.offsetBy(dx: dx, dy: dy)
                let headerSize = referenceSizeForHeader(inSection: indexPath.section)
                
                if scrollDirection == .vertical {
                    let offsetAdjustment = collectionView.bounds.origin.y + collectionView.bounds.height - frame.height
                    let previousFooterOffset = previousFooterOrigin.y + frame.size.height + headerSize.height
                    frame.origin.y = max(min(offsetAdjustment, frame.origin.y), previousFooterOffset)
                } else { // scrollDirection == .horizontal
                    let previousFooterOffset = previousFooterOrigin.x + frame.size.width + headerSize.width
                    let offsetAdjustment = collectionView.bounds.origin.x + collectionView.bounds.width - frame.width
                    frame.origin.x = max(min(offsetAdjustment, frame.origin.x), previousFooterOffset)
                }
                
                attributes.frame = frame
            case .implicit(_):
                assertionFailure("invalid layout mode")
                break
            }
            
            attributes.zIndex = StickySplitCollectionViewFlowLayout.headerFooterZIndex
            return attributes
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            guard let collectionView = self.collectionView,
                mainHeaderReferenceSize != .zero else {
                return nil
            }
            
            mainHeaderLayoutAttributes.frame = .zero
            let attributes = mainHeaderLayoutAttributes

            if scrollDirection == .vertical {
                var frame = attributes.frame
                frame.size = mainHeaderReferenceSize
                let maxY = frame.maxY
                
                let bounds = collectionView.bounds
                var y: CGFloat = min(maxY - mainHeaderMinimumReferenceSize.height, bounds.origin.y + collectionViewInset.top)
                
                let height: CGFloat
                switch layoutMode {
                case .horizontal(_):
                    height = max(maxY, -y + maxY)
                case .vertical:
                    height = max(0, -y + maxY)
                case .implicit(_):
                    assertionFailure("invalid layout mode")
                    height = 0
                }
                
                let maxHeight = mainHeaderMaximumReferenceSize.height
                attributes.zIndex = 0
                
                if (mainHeaderPinsToVisibleBounds && height <= mainHeaderMinimumReferenceSize.height) ||
                    layoutMode == .horizontal(.left) ||
                    layoutMode == .horizontal(.right) {
                    y = collectionView.contentOffset.y + collectionViewInset.top
                }
                
                switch mainHeaderZPosition {
                case .aboveAll:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderTopZIndex
                case .belowHeadersAndFooters:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderBelowHeaderFooterZIndex
                case .belowAll:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderBelowAllZIndex
                }
                
                if height > maxHeight && layoutMode == .vertical {
                    y += height - maxHeight
                }
                
                let x: CGFloat
                switch layoutMode {
                case .horizontal(.left):
                    x = frame.origin.x - collectionViewInset.left
                case .horizontal(.right):
                    x = collectionView.frame.width - collectionViewInset.right
                case .vertical:
                    x = frame.origin.x
                case .implicit(_):
                    assertionFailure("invalid layout mode")
                    x = 0
                }
                
                attributes.frame = CGRect(x: x,
                                          y: y,
                                          width: frame.size.width,
                                          height: height > maxHeight ? maxHeight : height)
            } else { // scrollDirection == .horizontal
                var frame = attributes.frame
                frame.size = mainHeaderReferenceSize
                let maxX = frame.maxX
                
                let bounds = collectionView.bounds
                var x = min(maxX - mainHeaderMinimumReferenceSize.width, bounds.origin.x + collectionViewInset.left)
                let width = max(0, -x + maxX)
                
                let maxWidth = mainHeaderMaximumReferenceSize.width
                attributes.zIndex = 0
                
                if mainHeaderPinsToVisibleBounds && width <= mainHeaderMinimumReferenceSize.width {
                    x = collectionView.contentOffset.x + collectionViewInset.left
                }
                
                switch mainHeaderZPosition {
                case .aboveAll:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderTopZIndex
                case .belowHeadersAndFooters:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderBelowHeaderFooterZIndex
                case .belowAll:
                    attributes.zIndex = StickySplitCollectionViewFlowLayout.mainHeaderBelowAllZIndex
                }
                
                if width > maxWidth {
                    x += width - maxWidth
                }
                
                attributes.frame = CGRect(x: x,
                                          y: frame.origin.y,
                                          width: width > maxWidth ? maxWidth : width,
                                          height: frame.size.height)
            }
            
            return attributes
        default:
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let dx = scrollDirection == .vertical ? 0 : mainHeaderReferenceSize.width
        let dy = scrollDirection == .vertical ? mainHeaderReferenceSize.height : 0
        let x = scrollDirection == .vertical ? rect.origin.x : rect.origin.x - mainHeaderReferenceSize.width
        let y = scrollDirection == .vertical ? rect.origin.y - mainHeaderReferenceSize.height : rect.origin.y
        let adjustedRect = CGRect(x: x,
                                  y: y,
                                  width: rect.width + dx,
                                  height: rect.height + dy)
        guard let _ = collectionView,
            let originalAttributes = super.layoutAttributesForElements(in: adjustedRect) else { return nil }
        
        var allAttributes = originalAttributes.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        
        var missingSections = Set<Int>()
        var cellsToAdd = Set<IndexPath>()
        
        allAttributes.enumerated().reversed().forEach { index, attribute in
            if attribute.representedElementCategory == .cell {
                missingSections.insert(attribute.indexPath.section)
                cellsToAdd.insert(attribute.indexPath)
                allAttributes.remove(at: index)
            }
            if attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                missingSections.insert(attribute.indexPath.section)
                allAttributes.remove(at: index)
            }
            if attribute.representedElementKind == UICollectionView.elementKindSectionFooter {
                missingSections.insert(attribute.indexPath.section)
                allAttributes.remove(at: index)
            }
        }
        
        missingSections.forEach { section in
            let indexPath = IndexPath(item: 0, section: section)
            if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                           at: indexPath) {
                allAttributes.append(headerAttributes)
            }
            if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                           at: indexPath) {
                allAttributes.append(footerAttributes)
            }
        }
        
        let rectMin = scrollDirection == .vertical ? rect.minY <= 0 : rect.minX <= 0
        let isMainHeaderInViewport = rectMin || mainHeaderPinsToVisibleBounds || layoutMode == .horizontal(.left) || layoutMode == .horizontal(.right)
        if isMainHeaderInViewport,
            let mainHeaderAttributes = layoutAttributesForSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                            at: IndexPath(index: 0)) {
            allAttributes.append(mainHeaderAttributes)
        }
        
        let adjustedCells = cellsToAdd.compactMap { indexPath in
            return layoutAttributesForItem(at: indexPath)
        }
        
        allAttributes += adjustedCells
        
        return allAttributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        switch layoutMode {
        case .horizontal(_):
            if scrollDirection != .vertical {
                let adjustedFrame = attributes.frame.offsetBy(dx: mainHeaderReferenceSize.width, dy: 0)
                attributes.frame = adjustedFrame
            }
        case .vertical:
            let dx = scrollDirection == .vertical ? 0 : mainHeaderReferenceSize.width
            let dy = scrollDirection == .vertical ? mainHeaderReferenceSize.height : 0
            let adjustedFrame = attributes.frame.offsetBy(dx: dx, dy: dy)
            attributes.frame = adjustedFrame
        case .implicit(_):
            assertionFailure("invalid layout mode")
            break
        }
        
        return attributes
    }
    
    open override var collectionViewContentSize: CGSize {
        guard let _ = collectionView?.superview else {
            return .zero
        }
        
        let size = super.collectionViewContentSize
        let dx = scrollDirection == .vertical ? 0 : mainHeaderReferenceSize.width
        let dy = scrollDirection == .vertical ? mainHeaderReferenceSize.height : 0
        var width = (layoutMode == .horizontal(.left) || layoutMode == .horizontal(.right)) ? size.width : size.width + dx
        if scrollDirection == .horizontal {
            width = size.width + dx
        }
        let height = (layoutMode == .horizontal(.left) || layoutMode == .horizontal(.right)) ? size.height : size.height + dy
        let newSize = CGSize(width: width, height: height)
        return newSize
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Private Properties
    
    /**
     A Boolean value indicating if the `sectionHeadersPinToVisibleBounds` is enabled. This is required because
     `sectionHeadersPinToVisibleBounds` is overriden to always be `false` since this layout requires 
     adjustments to the header positions.
     
     Defaults to `false`
     */
    private(set) var isStickyHeadersEnabled = false
    
    /**
     A Boolean value indicating if the `sectionFootersPinToVisibleBounds` is enabled. This is required because
     `sectionFootersPinToVisibleBounds` is overriden to always be `false` since this layout requires 
     adjustments to the footer positions.
     
     Defaults to `false`
     */
    private(set) var isStickyFootersEnabled = false
    
    private var initialInset: UIEdgeInsets?
    
    private var flowDelegate: UICollectionViewDelegateFlowLayout? {
        return collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }
    
    private var mainHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                              with: IndexPath(index: 0))
    
    private static let headerFooterZIndex: Int = 1024
    private static let mainHeaderTopZIndex: Int = 2000
    private static let mainHeaderBelowHeaderFooterZIndex: Int = headerFooterZIndex - 1
    private static let mainHeaderBelowAllZIndex: Int = -1024
    
    // MARK: - Private Methods
    private func referenceSizeForFooter(inSection section: Int) -> CGSize {
        guard let collectionView = collectionView, let delegate = flowDelegate else {
            return footerReferenceSize
        }
        
        return delegate.collectionView?(collectionView,
                                        layout: collectionView.collectionViewLayout,
                                        referenceSizeForFooterInSection: section) ?? footerReferenceSize
    }
    
    private func referenceSizeForHeader(inSection section: Int) -> CGSize {
        guard let collectionView = collectionView, let delegate = flowDelegate else {
            return headerReferenceSize
        }
        
        return delegate.collectionView?(collectionView,
                                        layout: collectionView.collectionViewLayout,
                                        referenceSizeForHeaderInSection: section) ?? headerReferenceSize
    }
}

/**
 The layout modes of a `StickySplitCollectionViewFlowLayout`
 */
public enum LayoutMode {
    /**
     The layout mode is split with the main header located to the side defined by the mode and the cells aligned to the opposite.
     */
    case horizontal(_ mode: HorizontalLayoutMode)
    
    /**
     The mode that implicitly converts between the horizontal and vertical modes based on the collection view bounds.
     */
    case implicit(_ mode: HorizontalLayoutMode)
    
    /**
     The mode where the layout operates similarly to `UICollectionViewFlowLayout`.
     */
    case vertical
}

extension LayoutMode: Equatable {
    public static func == (lhs: LayoutMode, rhs: LayoutMode) -> Bool {
        switch (lhs, rhs) {
        case (.vertical, .vertical):
            return true
        case let (.implicit(a), .implicit(b)):
            return a == b
        case let (.horizontal(a), .horizontal(b)):
            return a == b
        case (.vertical, .implicit(_)):
            return false
        case (.vertical, .horizontal(_)):
            return false
        case (.implicit(_), .horizontal(_)):
            return false
        case (.implicit(_), .vertical):
            return false
        case (.horizontal(_), .vertical):
            return false
        case (.horizontal(_), .implicit(_)):
            return false
        }
    }
}

/**
 The layout modes of a `StickySplitCollectionViewFlowLayout` in a `.horozontal` layout
 */
public enum HorizontalLayoutMode {
    /**
     The mode where the main header is aligned to the left
     */
    case left
    
    /**
     The mode where the main header is aligned to the right
     */
    case right
}

/**
 The z-position layering behavior of a `StickySplitCollectionViewFlowLayout` main header
 */
public enum MainHeaderZPositionMode {
    /**
     The mode where the main header is layered above headers, footers, and cells
    */
    case aboveAll
    
    /**
     The mode where the main header is layered below headers and footers, but above cells
    */
    case belowHeadersAndFooters
    
    /**
     The mode where the main header is layered below all other cells
    */
    case belowAll
}
