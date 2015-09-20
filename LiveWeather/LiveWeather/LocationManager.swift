//
//  LocationManager.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: NSObjectProtocol {
    func locationManagerDidUpdate(locationManager: LocationManager, location: CLLocation)
}

class LocationManager: NSObject {
    private let locationMagaer = CLLocationManager()
    var delegate: LocationManagerDelegate?
    static let shareManager = LocationManager()
    override init() {
        super.init()
        locationMagaer.delegate = self
        locationMagaer.desiredAccuracy = kCLLocationAccuracyBest
    }
    func requesNewLocation() {
        locationMagaer.requestAlwaysAuthorization()
        locationMagaer.requestWhenInUseAuthorization()
        locationMagaer.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            delegate?.locationManagerDidUpdate(self, location: location)
            print(location)
            locationMagaer.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
}