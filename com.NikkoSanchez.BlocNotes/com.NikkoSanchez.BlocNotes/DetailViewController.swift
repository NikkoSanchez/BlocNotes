//
//  DetailViewController.swift
//  com.NikkoSanchez.BlocNotes
//
//  Created by Nikko on 9/21/16.
//  Copyright © 2016 Nikko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var noteText: UITextView!
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
            UIApplication.shared.delegate as! AppDelegate
        
        
        detailItem?.setValue(noteText.text, forKey: "body")
        
        //save title value
        detailItem?.setValue(noteTitle.text, forKey: "title")
        
        do {
            appDelegate.saveContext()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let note = self.noteText {
                note.text = detail.value(forKey: "body") as? String
            }
            if let title = self.noteTitle {
                title.text = detail.value(forKey: "title") as? String
                //title.text = (detail.value(forKey: "title") as AnyObject).description
            }
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.saveNote()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add sharebutton programmatically to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        
        self.configureView()
        
        let tapToEdit = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapFunction))
        tapToEdit.numberOfTapsRequired = 1
        noteText.addGestureRecognizer(tapToEdit)
        
        let tapToEnd = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapToEndFunction))
        tapToEnd.numberOfTapsRequired = 2
        noteTitle.addGestureRecognizer(tapToEnd)
        
    }
    
    // add tapFunction
    func tapFunction(sender: UITapGestureRecognizer) {
        noteText.isEditable = true
    }
    
    func tapToEndFunction(sender: UITapGestureRecognizer) {
        noteText.isEditable = false
    }
    
    /*func textViewDidEndEditing(_ textView: UITextView) {
        resignFirstResponder()
    }
    */
    
    func shareButton() {
        var itemsToShare = [String]()
        let detail = self.detailItem
        let noteTitle = (detail?.value(forKey: "title")! as AnyObject).description
        let noteBody = (detail?.value(forKey: "body")! as AnyObject).description
        itemsToShare.append(noteTitle!)
        itemsToShare.append(noteBody!)
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
  /*  func NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorTypes: UIDataDetectorTypes) -> NSTextCheckingTypes {
        var textCheckingType: NSTextCheckingResult.CheckingType = []
        
        if dataDetectorTypes.contains(.address){
            textCheckingType.insert(.address)
        }
        
        if dataDetectorTypes.contains(.link){
            textCheckingType.insert(.link)
        }
        
        if dataDetectorTypes.contains(.calendarEvent){
            textCheckingType.insert(.date)
        }
        
        if dataDetectorTypes.contains(.phoneNumber){
            textCheckingType.insert(.phoneNumber)
        }
        
        return textCheckingType.rawValue
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

