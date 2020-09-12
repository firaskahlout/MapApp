//
//  Location+CoreData.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/12/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//
//

import Foundation
import CoreData

public class Location: NSManagedObject {
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    
    var item: LocationItem {
        .init(name: name, latitude: latitude, longitude: longitude)
    }
}

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
}
