//
//  MapviewControllerViewController.swift
//  LiveWeather
//
//  Created by phuc on 9/20/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import UIKit
import MapKit

class MapviewControllerViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    
    var anotation: MKPointAnnotation! {
        didSet {
            if let Ananotation = anotation {
                zoomMapViewToLocation(Ananotation.coordinate)
                mapview.addAnnotation(Ananotation)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapview.showsCompass = true
        mapview.showsScale = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var dismissMapView: UIButton!
    @IBAction func dismissButtonPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func zoomMapViewToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        let region = MKCoordinateRegion(center: location, span: span)
        mapview.setRegion(region, animated: true)
    }
}

extension MapviewControllerViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let aView = mapView.dequeueReusableAnnotationViewWithIdentifier("anotationView") ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "anotationView")
        aView.annotation = annotation
        aView.canShowCallout = true
        return aView
    }
}
