//
//  MediaPlayerHeaderCollectionReusableView.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 10/14/18.
//

import UIKit

class MediaPlayerHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var pageControl: UIPageControl!
}

extension MediaPlayerHeaderCollectionReusableView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
