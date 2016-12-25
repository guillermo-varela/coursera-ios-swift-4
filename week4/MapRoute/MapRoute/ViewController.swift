//
//  ViewController.swift
//  MapRoute
//
//  Created by Guillermo Varela on 12/25/16.
//  Copyright © 2016 Guillermo Varela. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomSlider: UISlider!

    private let locationManager = CLLocationManager()
    private var lastLocationAnnotated: CLLocation?
    private var distanceTraveled: Double = 0.0
    private let distanceFilter = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = distanceFilter
        locationManager.requestWhenInUseAuthorization()

        zoomSlider.transform = CGAffineTransform.init(rotationAngle: CGFloat(-M_PI_2))
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
            if status == .denied {
                let alertController = UIAlertController(title: "Error", message: "Al no aceptar, no podemos presentar tu ubicación", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        mapView.centerCoordinate = location.coordinate

        var distanceMeters = 0.0
        if lastLocationAnnotated != nil {
            distanceMeters = abs((lastLocationAnnotated!.distance(from: location)))
        } else {
            zoomChanged()
        }

        distanceTraveled += distanceMeters

        if lastLocationAnnotated == nil || distanceMeters >= distanceFilter {
            let annotation = MKPointAnnotation()
            let latitude = String(format: "%.2f", location.coordinate.latitude)
            let longitude = String(format: "%.2f", location.coordinate.longitude)

            annotation.title = "\(latitude), \(longitude)"
            annotation.subtitle = "\(String(format: "%.2f", distanceTraveled)) mts"
            annotation.coordinate = location.coordinate

            mapView.addAnnotation(annotation)
            lastLocationAnnotated = location
        }
    }

    @IBAction func toggleMapType(sender: UIButton) {
        let title = sender.titleLabel?.text
        switch title! {
        case "Satélite":
            mapView.mapType = .satellite
        case "Híbrido":
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }

    @IBAction func zoomChanged() {
        let miles = Double(zoomSlider.value)
        let delta = miles / 69.0

        var currentRegion = mapView.region
        currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        mapView.region = currentRegion
    }
}

