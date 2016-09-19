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
        addMemeButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MemeTableViewController.createMeme))
        //Display addMemeButton
        self.navigationItem.rightBarButtonItem = addMemeButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Update the memes array to update view
        updateMemes()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Pass in number of memes in array
        return memes.count
    }
    
    //Create individual cells for table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeCell") as UITableViewCell!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        cell?.textLabel?.text = meme.topText! + " " + meme.bottomText!
        cell?.detailTextLabel?.text = ""
        cell?.imageView?.image = meme.memedImage
        return cell!
    }
    
    //Segue to detail view when meme is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeViewController") as! MemeViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        detailController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    
    //Meme Functions
    
    //Segue to Meme Editor
    func createMeme() {
        self.dismiss(animated: true, completion: nil)
        tabBarController?.hidesBottomBarWhenPushed = true
        self.performSegue(withIdentifier: "createMeme", sender: self)
    }
    
    //Update Memes array in AppDelegate
    func updateMemes(){
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }

}
