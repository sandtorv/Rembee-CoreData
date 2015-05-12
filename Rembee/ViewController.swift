//
//  ViewController.swift
//  Rembee
//
//  Created by Sebastian Sandtorv on 29/04/15.
//  Copyright (c) 2015 Protodesign. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate {
    
    // Initialise variables
    var refreshControl = UIRefreshControl()
    
    // Initialise IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var barButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Rembee"
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
        var alert = UIAlertController(title: "Add Rembee list", message: "Type in the name of new Rembee list!", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Rembee list name"
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Default
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){saveList("\(textField.text)")}
            self.sortArray()
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
        if(fetchCoreData()){
            println("fetchCoreData")
            items.sort() { $1.valueForKey("listID") as! Int > $0.valueForKey("listID") as! Int }
        } else{
            printError("Error")
        }
        if(items.count > 0){
            tableView.hidden = false
        } else{
            tableView.hidden = true
        }
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: UITableViewControllerxw
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var attributes = [NSStrikethroughStyleAttributeName : 0]
        var item = items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! tableCell
        item.setValue(indexPath.row, forKey: "listID")
        cell.tintColor = .lightGrayColor()
        cell.title.textColor = .blackColor()
        cell.accessoryType = .None
        cell.backgroundColor = cellBGColorNormal(indexPath.row)
        cell.title.attributedText = NSAttributedString(string: item.valueForKey("listName") as! String, attributes: attributes)
        print(item.valueForKey("listID") as! Int)
        println(" for row: \(indexPath.row)")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item : NSManagedObject = items[indexPath.row]
        listUUID = item.valueForKey("listUUID") as! String
        listTitle = item.valueForKey("listName") as! String
    }
    
    // Determine whether a given row is eligible for reordering or not.
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool{
        return true
    }
    
    // Process the row move. This means updating the data model to correct the item details.
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!)
    {
        let item : NSManagedObject = items[sourceIndexPath.row]
        items.removeAtIndex(sourceIndexPath.row)
        items.insert(item, atIndex: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item : NSManagedObject = items[indexPath.row]
            listUUID = item.valueForKey("listUUID") as! String
            if(fetchDetailCoreData()){
                detailItems.removeAll()
            }
            var object: Int = indexPath.row
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            context.deleteObject(items[object] as NSManagedObject)
            items.removeAtIndex(object)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            context.save(nil)
            delay(0.15, {self.sortArray()})
        }
    }
    
}

