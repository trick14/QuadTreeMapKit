//
//  ViewController.swift
//  QuadTreeWithMapKit
//
//  Created by Ryan Han on 6/1/18.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    let root = QuadNode(rect: MKMapRectWorld)
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    let annotations: [SampleAnnotation] = {
        guard let url = Bundle.main.url(forResource: "SessionData", withExtension: "csv") else {
            return []
        }
        
        do {
            var items: [SampleAnnotation] = []
            let string = try String(contentsOf: url, encoding: .utf8)
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                //5842041f4e65fad6a7708816,34.0402,-118.735,Zuma Beach,Spot,Zuma Beach,LA County,6:30,4,2,20,10
                let columns = line.components(separatedBy: ",")
                guard columns.count == 12 else { continue }
                let lat = Double(columns[1]) ?? 0
                let lon = Double(columns[2]) ?? 0
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let annotation = SampleAnnotation(coordinate: coordinate)
                items.append(annotation)
            }
            return items
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create QuadTree
        for anno in annotations {
            root.add(point: anno)
        }
        
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PIN")
        
        let coord = CLLocationCoordinate2D(latitude: 33.64777373857072,
                                           longitude: -117.9938939098174)
        let camera = MKMapCamera(lookingAtCenter: coord,
                                 fromEyeCoordinate: coord,
                                 eyeAltitude: 522.0461288759)
        mapView.setCamera(camera, animated: false)
    }
    
    //MARK:- private
    fileprivate func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        let rect = mapView.visibleMapRect
        guard let points = root.points(in: rect) as? [SampleAnnotation] else { return }
        mapView.addAnnotations(points)
    }
    
    //MARK:- MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PIN", for: annotation)
        return annotationView
    }
}

