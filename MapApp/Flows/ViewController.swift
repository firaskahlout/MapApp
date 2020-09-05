//
//  ViewController.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/5/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

final class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: Proparities
    
    private let locationManager = CLLocationManager()
    private var currentPointAnnotation: MKPointAnnotation?
    private var gesture: UILongPressGestureRecognizer!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        configureMapView()
    }
}

// MARK: - Configurations

private extension ViewController {
    func configureGesture() {
        gesture = .init(target: self, action: #selector(longTapHandler))
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)
    }
    
    func configureMapView() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.startUpdatingLocation()
    }
}

// MARK: - Helpers

private extension ViewController {
    
    @objc func longTapHandler() {
        guard gesture.state == .began else { return }
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
    }
    
    func actionHandler() -> ActionsViewController.ActionHandler {
        { [weak self] action in
            switch action {
            case let .share(coordinate):
                self?.presentActivityController(with: coordinate)
            case .save: break
            }
        }
    }
    
    func presentActivityController(with coordinate: CLLocationCoordinate2D) {
        let urlString = "https://maps.apple.com?ll=\(coordinate.latitude),\(coordinate.longitude)"
        guard let url = URL(string: urlString) else { return }
        let activityControler = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        present(activityControler, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = manager.location else { return }
        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        let region = MKCoordinateRegion(
            center: center,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
        
        if let currentPointAnnotation = currentPointAnnotation {
            mapView.removeAnnotation(currentPointAnnotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "You"
        mapView.addAnnotation(annotation)
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        guard let coordinate = view.annotation?.coordinate else { return }
        let actionsView = ActionsViewController(
            coordinate: coordinate,
            handler: actionHandler()
        )
        actionsView.modalPresentationStyle = .popover
        actionsView.preferredContentSize = .init(width: 320, height: 100)
        actionsView.popoverPresentationController?.delegate = actionsView
        actionsView.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        actionsView.popoverPresentationController?.sourceView = view
        present(actionsView, animated: true)
    }
}
