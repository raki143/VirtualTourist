//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 18/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    convenience init(id: NSNumber, url: String,  context : NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo",
                                                in: context){
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.url = url
        } else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    
}
