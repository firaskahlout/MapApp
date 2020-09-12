//
//  LocationItem.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/12/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationItem {
    let name: String?
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: .init(latitude), longitude: .init(longitude))
    }
}

// MARK: - LocationItem.ActionType

extension LocationItem {
    enum ActionType {
        case share(_ location: LocationItem)
        case save(_ location: LocationItem)
        case delete(_ location: LocationItem)
    }
}

// MARK: - Equatable

extension LocationItem: Equatable {
    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}
