//
//  CoreDataHelper.swift
//  Rembee
//
//  Created by Sebastian Sandtorv on 29/04/15.
//  Copyright (c) 2015 Protodesign. All rights reserved.
//

import UIKit
import CoreData

var items = [NSManagedObject]()
var detailItems = [NSManagedObject]()

var listUUID = ""
var listTitle = ""

var error: NSError?

// fetch CoreData elements. Returns true if fetched OK.
func fetchCoreData() -> Bool{
    // CoreData variables
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext = appDelegate.managedObjectContext!
    var entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: managedContext)
    // Fetch data from CoreData
    let fetchRequest = NSFetchRequest(entityName:"List")
    let sortDescriptor1 = NSSortDescriptor(key: "listID", ascending: true)
    
    fetchRequest.sortDescriptors = [sortDescriptor1]
    
    let fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as! [NSManagedObject]?
    if let results = fetchedResults {
        items = results
        return true
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
        return false
    }
}

// fetch CoreData elements. Returns true if fetched OK.
func fetchDetailCoreData() -> Bool{
    // CoreData variables
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext = appDelegate.managedObjectContext!
    var entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext)
    // Fetch data from CoreData
    let fetchRequest = NSFetchRequest(entityName:"Item")
    fetchRequest.predicate = NSPredicate(format: "(listUUID = %@)", listUUID)
    
    let sortDescriptor1 = NSSortDescriptor(key: "itemID", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor1]
    
    let fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as! [NSManagedObject]?
    if let results = fetchedResults {
        detailItems = results
        return true
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
        return false
    }
}

func saveList(name: String) {
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext = appDelegate.managedObjectContext!
    var entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: managedContext)
    var item = NSManagedObject(entity: entity!,insertIntoManagedObjectContext:managedContext)
    // Set date object
    item.setValue(name, forKey: "listName")
    item.setValue(NSUUID().UUIDString, forKey: "listUUID")
    item.setValue(items.count, forKey: "listID")
    
    if !managedContext.save(&error) {
        println("Could not save \(error), \(error?.userInfo)")
    } else{
        items.append(item)
    }
}


func saveItem(name: String) {
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext = appDelegate.managedObjectContext!
    var entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext)
    var item = NSManagedObject(entity: entity!,insertIntoManagedObjectContext:managedContext)
    // Set date object
    item.setValue(name, forKey: "itemName")
    item.setValue(false, forKey: "completed")
    item.setValue(detailItems.count, forKey: "itemID")
    item.setValue(NSDate().timeIntervalSince1970, forKey: "addedDate")
    item.setValue(listUUID, forKey: "listUUID")
    
    if !managedContext.save(&error) {
        println("Could not save \(error), \(error?.userInfo)")
    } else{
        detailItems.append(item)
    }
}

func clickRembee(indexPath: NSIndexPath) -> Bool{
    var item = detailItems[indexPath.row]
    var completed: Bool = item.valueForKey("completed") as! Bool
    if(completed){
        item.setValue(false, forKey: "completed")
        item.setValue(-1, forKey: "itemID")
    } else{
        item.setValue(true, forKey: "completed")
        item.setValue(detailItems.count+1, forKey: "itemID")
    }
    return true
}

