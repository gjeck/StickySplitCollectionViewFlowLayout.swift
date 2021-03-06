//
//  MathUtils.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 12/7/18.
//

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
    return min(max(value, minValue), maxValue)
}
