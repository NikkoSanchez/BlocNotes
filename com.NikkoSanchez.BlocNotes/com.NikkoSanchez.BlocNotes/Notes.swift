//
//  Notes.swift
//  com.NikkoSanchez.BlocNotes
//
//  Created by Nikko on 10/17/16.
//  Copyright © 2016 Nikko. All rights reserved.
//

import Foundation
import CoreData

class Notes: NSManagedObject {
    
    @NSManaged var body: String
    @NSManaged var timeStamp: NSDate
    @NSManaged var title: String
}
