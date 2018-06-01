//
//  SampleAnnotation.swift
//  QuadTreeWithMapKit
//
//  Created by Ryan Han on 6/1/18.
//

import Foundation
import MapKit

class SampleAnnotation: NSObject, MKAnnotation, QuadPoint {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
