//
//  MemeTableViewController.swift
//
//  Created by Cody Fazio on 4/12/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {

    //Create array for saved Memes
    var memes: [Meme]!
    //Create bar button for addding new Memes
    var addMemeButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        
        //Update the memes array to update view
        updateMemes()
        //Add attributes and link via segue to Meme Editor
        addMemeButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createMeme")
        //Display addMemeButton
        self.navigationItem.rightBarButtonItem = addMemeButton
    }
    
    override func viewWillAppear(animated: Bool) {
        //Update the memes array to update view
        updateMemes()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Pass in number of memes in array
        return memes.count
    }
    
    //Create individual cells for table view
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell") as UITableViewCell!
        let meme = self.memes[indexPath.row]
        
        cell.textLabel?.text = meme.topText! + " " + meme.bottomText!
        cell.detailTextLabel?.text = ""
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    //Segue to detail view when meme is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        detailController.meme = self.memes[indexPath.row]
        detailController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    
    //Meme Functions
    
    //Segue to Meme Editor
    func createMeme() {
        self.dismissViewControllerAnimated(true, completion: nil)
        tabBarController?.hidesBottomBarWhenPushed = true
        self.performSegueWithIdentifier("createMeme", sender: self)
    }
    
    //Update Memes array in AppDelegate
    func updateMemes(){
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }

}