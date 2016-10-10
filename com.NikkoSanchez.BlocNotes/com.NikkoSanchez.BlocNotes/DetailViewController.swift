//
//  DetailViewController.swift
//  com.NikkoSanchez.BlocNotes
//
//  Created by Nikko on 9/21/16.
//  Copyright © 2016 Nikko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var noteText: UITextField!
    @IBOutlet weak var noteTitle: UITextField!
    

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
            //self.saveNote()
        }
    }
    
    
    func saveNote() {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        detailItem?.setValue(noteText.text, forKey: "body")
        
        //save title value
        detailItem?.setValue(noteTitle.text, forKey: "title")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let note = self.noteText {
                note.text = detail.valueForKey("body")!.description
            }
            if let title = self.noteTitle {
                title.text = detail.valueForKey("title")?.description
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.saveNote()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

