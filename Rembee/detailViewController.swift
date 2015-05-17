//
//  detailViewController.swift
//  Rembee
//
//  Created by Sebastian Sandtorv on 03/05/15.
//  Copyright (c) 2015 Protodesign. All rights reserved.
//

import UIKit
import CoreData

class detailViewController: UIViewController, UITableViewDelegate {
    
    // Initialise variables
    var refreshControl = UIRefreshControl()
    
    // Initialise IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var barButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = listTitle
        barButton.title = "Edit"
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.layoutMargins = UIEdgeInsetsZero
        refreshControl.addTarget(self, action: Selector("sortArray"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        sortArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addRembeeButton(sender: AnyObject) {
        var alert = UIAlertController(title: "Add Rembee item", message: "Type in the item to Rembee it!", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Add Rembee item"
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Default
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){saveItem("\(textField.text)")}
            self.sortArray()
        }))
        alert.addAction(UIAlertAction(title: "Add another", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){saveItem("\(textField.text)")}
            self.sortArray()
            self.addRembeeButton(self)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func editListButton(sender: AnyObject) {
        if tableView.editing{
            tableView.setEditing(false, animated: false)
            barButton.style = UIBarButtonItemStyle.Plain
            barButton.title = "Edit"
        }
        else{
            tableView.setEditing(true, animated: false)
            barButton.title = "Done"
            barButton.style =  UIBarButtonItemStyle.Done
        }
        sortArray()
    }
    
    // MARK: CoreData
    func sortArray(){
        if(fetchDetailCoreData()){
            println("fetchCoreData")
            detailItems.sort() { $1.valueForKey("itemID") as! Int > $0.valueForKey("itemID") as! Int }
            // TODO: Fix sort by itemID and completed
//            detailItems.sort() { $1.valueForKey("completed") as! Bool == true && $0.valueForKey("completed") as! Bool != true }
            tableView.reloadData()
        } else{
            printError("Error")
        }
        if(detailItems.count > 0){
            tableView.hidden = false
        } else{
            tableView.hidden = true
        }
        refreshControl.endRefreshing()
    }
    
    // MARK: UITableViewControllerxw
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var attributes = [NSStrikethroughStyleAttributeName : 0]
        var item = detailItems[indexPath.row]
        var completed: Bool = item.valueForKey("completed") as! Bool
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! tableCell
        item.setValue(indexPath.row, forKey: "itemID")
        cell.tintColor = .lightGrayColor()
        cell.title.textColor = .blackColor()
        if(completed){
            attributes = [NSStrikethroughStyleAttributeName : 1]
            cell.accessoryType = .Checkmark
            cell.title.textColor = .lightGrayColor()
            cell.backgroundColor = cellBGColorComplete(indexPath.row)
            
        } else{
            cell.accessoryType = .None
            cell.backgroundColor = cellBGColorNormal(indexPath.row)
        }
        cell.title.attributedText = NSAttributedString(string: item.valueForKey("itemName") as! String, attributes: attributes)
        print(item.valueForKey("itemID") as! Int)
        println(" for row: \(indexPath.row)")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        clickRembee(indexPath) ? sortArray() : printError("Error")
    }
    
    // Determine whether a given row is eligible for reordering or not.
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool{
        return true
    }
    
    // Process the row move. This means updating the data model to correct the item indices.
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!)
    {
        let item : NSManagedObject = detailItems[sourceIndexPath.row]
        detailItems.removeAtIndex(sourceIndexPath.row)
        detailItems.insert(item, atIndex: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            var object: Int = indexPath.row
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            context.deleteObject(detailItems[object] as NSManagedObject)
            detailItems.removeAtIndex(object)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            context.save(nil)
            delay(0.15, {self.sortArray()})
        }
    }
    
}

