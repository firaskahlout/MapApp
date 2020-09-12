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
    private var locations = [Location]()
    private let manager = DataManager.shared
    private let locationManager = CLLocationManager()
    private var currentPointCoordinate: CLLocationCoordinate2D?
    private var gesture: UILongPressGestureRecognizer!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocations()
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
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        makeAnnotation(for: touchMapCoordinate)
    }
    
    func fetchLocations() {
        guard let locations = manager.fetch(Location.self) else { return }
        self.locations = locations
        self.locations.forEach { makeAnnotation(for: $0.item.coordinate, title: $0.name) }
    }
    
    func makeAnnotation(for coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func reloadAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        fetchLocations()
    }
    
    func actionHandler() -> ActionsViewController.ActionHandler {
        { [weak self] action in
            switch action {
            case let .share(location):
                self?.share(location: location)
            case let .save(location):
                self?.save(location: location)
            case let .delete(location):
                self?.delete(location: location)
            }
        }
    }
    
    func save(location: LocationItem) {
        let alert = UIAlertController(
            title: "New Location",
            message: "Add a location name",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let nameToSave = textField.text
            else { return }
            let locationObj = Location(context: self.manager.context)
            locationObj.name = nameToSave
            let coordinate = location.coordinate
            locationObj.latitude = coordinate.latitude
            locationObj.longitude = coordinate.longitude
            self.manager.save()
            self.reloadAnnotations()
        }
        alert.addTextField()
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    func delete(location: LocationItem) {
        guard let selectedLocation = locations.first(where: { $0.item == location }) else { return }
        manager.delete(selectedLocation)
        reloadAnnotations()
    }
    
    func share(location: LocationItem) {
        let urlString = "https://maps.apple.com?ll=\(location.latitude),\(location.longitude)"
        guard let url = URL(string: urlString) else { return }
        var items: [Any] = [url]
        if let title = location.name { items = [title, url] }
        let activityControler = UIActivityViewController(
            activityItems: items,
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
        reloadAnnotations()
        makeAnnotation(for: center, title: "You")
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        guard let annotation = view.annotation else { return }
        let location = LocationItem(
            name: annotation.title as? String,
            latitude: annotation.coordinate.latitude,
            longitude: annotation.coordinate.longitude
        )
        let actionsView = ActionsViewController(
            location: location,
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
