//
//  MasterViewController.swift
//  com.NikkoSanchez.BlocNotes
//
//  Created by Nikko on 9/21/16.
//  Copyright © 2016 Nikko. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var detailViewController: DetailViewController?
    var managedObjectContext: NSManagedObjectContext?
    
    var filteredNotes : [Notes]?
    var searchPredicate : NSPredicate?
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //Add search controller delegate
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
   //     searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController?.searchBar
        self.tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = self.searchController?.searchBar.text
        if let searchText = searchText {
            searchPredicate = NSPredicate(format: "title contains[c] %@ OR body contains[c] %@", searchText, searchText)
            
            if let managedObjectContext = managedObjectContext {
            let fetchRequest = NSFetchRequest<Notes>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notes", in: managedObjectContext)
            fetchRequest.predicate = searchPredicate
            try? filteredNotes = managedObjectContext.fetch(fetchRequest)
    
            self.tableView.reloadData()
            print(searchPredicate)
            print(filteredNotes?.count)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context)
        
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        //newManagedObject.setValue(NSDate(), forKey: "timeStamp")
        newManagedObject.setValue("New Note", forKey: "body")
        
        //make a new blank object for title
        newManagedObject.setValue(NSString(), forKey: "title")
        
        
        // Save the context.
        do {
            try context.save()
        } catch let error as NSError{
            print("Could not save \(error), \(error.userInfo)")
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchPredicate == nil{
            return self.fetchedResultsController.sections?.count ?? 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil{
            let sectionInfo = self.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return filteredNotes?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if searchPredicate == nil {
            let object = self.fetchedResultsController.object(at: indexPath)
            self.configureCell(cell, withObject: object)
        } else {
            
            let note = filteredNotes?[indexPath.row]
                cell.textLabel?.text = note?.title
                cell.detailTextLabel?.text = note?.body
        
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) )
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
       
        // cell.textLabel!.text = object.valueForKey("timeStamp")?.description
        cell.textLabel!.text = object.value(forKey: "title") as? String
        cell.detailTextLabel!.text = object.value(forKey: "body") as? String
        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Notes> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Notes>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController<Notes>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Notes>? //!//? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, withObject: anObject as! NSManagedObject)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       
            self.tableView.endUpdates()
    }

    
    // MARK: UISearchBar
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: self.searchController)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.searchPredicate = nil
        self.filteredNotes?.removeAll()
        self.tableView.reloadData()
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        print("PRESENT CONTROLLER")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        print("WILL PRESENT")
    }
    
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

