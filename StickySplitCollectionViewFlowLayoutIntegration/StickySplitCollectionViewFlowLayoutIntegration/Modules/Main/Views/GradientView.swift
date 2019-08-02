//
//  GradientView.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 12/7/18.
//

import UIKit

enum GradientViewDirection {
    case vertical
    case horizontal
}

@IBDesignable class GradientView: UIView {
    var direction: GradientViewDirection = .vertical
    @IBInspectable var startColor: UIColor = .clear {
        didSet { render() }
    }
    @IBInspectable var endColor: UIColor = .clear {
        didSet { render() }
    }
    @IBInspectable var skew: CGFloat = 0.0 {
        didSet { render() }
    }
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        render()
    }
    
    func render() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        switch direction {
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0 - skew, y: 0.5)
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0 - skew)
        }
    }
}
