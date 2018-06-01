//
//  QuadNode.swift
//  QuadTreeWithMapKit
//
//  Created by Ryan Han on 6/1/18.
//

import Foundation
import MapKit

extension MKMapRect {
    var nw: MKMapRect {
        return MKMapRectMake(origin.x,
                             origin.y,
                             size.width / 2,
                             size.height / 2)
    }
    
    var ne: MKMapRect {
        return MKMapRectMake(origin.x + size.width / 2,
                             origin.y,
                             size.width / 2,
                             size.height / 2)
    }
    
    var sw: MKMapRect {
        return MKMapRectMake(origin.x,
                             origin.y + size.height / 2,
                             size.width / 2,
                             size.height / 2)
    }
    
    var se: MKMapRect {
        return MKMapRectMake(origin.x + size.width / 2,
                             origin.y + size.height / 2,
                             size.width / 2,
                             size.height / 2)
    }
}

protocol QuadPoint {
    var coordinate: CLLocationCoordinate2D { get }
}

class QuadNode {
    struct Child {
        let ne: QuadNode
        let nw: QuadNode
        let se: QuadNode
        let sw: QuadNode
    }
    
    let rect: MKMapRect
    fileprivate(set) var points: [QuadPoint] = []
    fileprivate(set) var child: Child?
    static let maxCapacity: UInt = 3
    
    static func worldNode() -> QuadNode {
        return QuadNode(rect: MKMapRectWorld)
    }
    
    init(rect: MKMapRect) {
        self.rect = rect
    }
    
    @discardableResult
    func add(point: QuadPoint) -> Bool {
        let mkPoint = MKMapPointForCoordinate(point.coordinate)
        guard MKMapRectContainsPoint(rect, mkPoint) else { return false }
        
        points.append(point)
        
        guard QuadNode.maxCapacity > 0 else {
            fatalError("maxCapacity must be greater than 0")
        }
        guard points.count > QuadNode.maxCapacity else { return true }
        
        // if number of points are exceeded maxCapacity and child is nil, create child.
        if child == nil {
            child = Child(ne: QuadNode(rect: rect.ne),
                          nw: QuadNode(rect: rect.nw),
                          se: QuadNode(rect: rect.se),
                          sw: QuadNode(rect: rect.sw))
            
            // add previous points
            for point in points {
                guard let child = child else { continue }
                guard !child.ne.add(point: point) else { continue }
                guard !child.nw.add(point: point) else { continue }
                guard !child.se.add(point: point) else { continue }
                guard !child.sw.add(point: point) else { continue }
            }
            return true
        }
        
        // Add coord to the child
        guard let child = child else { return true }
        guard !child.ne.add(point: point) else { return true }
        guard !child.nw.add(point: point) else { return true }
        guard !child.se.add(point: point) else { return true }
        guard !child.sw.add(point: point) else { return true }
        return true // shouldn't happen
    }
    
    @discardableResult
    func add(points: [QuadPoint]) -> UInt {
        var success: UInt = 0
        for point in points {
            guard add(point: point) else { continue }
            success += 1
        }
        return success
    }
    
    func points(in rect: MKMapRect) -> [QuadPoint] {
        // no intersection, return nothing
        guard MKMapRectIntersectsRect(self.rect, rect) else {
            return []
        }
        
        // if current rect is in the target rect, return all points
        if MKMapRectContainsRect(rect, self.rect) {
            return points
        }
        
        
        var result: [QuadPoint] = []
        if let child = child {
            // if child is not nil, iterate each child to get the points in the child's rect
            result.append(contentsOf: child.ne.points(in: rect))
            result.append(contentsOf: child.nw.points(in: rect))
            result.append(contentsOf: child.se.points(in: rect))
            result.append(contentsOf: child.sw.points(in: rect))
            
        } else {
            // if child is nil, just iterate and return points in the target rect
            // as long as the maxCapacity is low, it will not take long time
            
            for point in points {
                let mkPoint = MKMapPointForCoordinate(point.coordinate)
                guard MKMapRectContainsPoint(rect, mkPoint) else { continue }
                result.append(point)
            }
        }
        return result
    }
}
