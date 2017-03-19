//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 18/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var imageData: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
