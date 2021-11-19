//
//  Menuitem+CoreDataProperties.swift
//  open_with_vsc_mac
//
//  Created by 谢渊 on 2021/11/16.
//
//

import Foundation
import CoreData


extension Menuitem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Menuitem> {
        return NSFetchRequest<Menuitem>(entityName: "Menuitem")
    }

    @NSManaged public var label: String?
    @NSManaged public var path: String?
    @NSManaged public var times: Int64

}

extension Menuitem : Identifiable {

}
