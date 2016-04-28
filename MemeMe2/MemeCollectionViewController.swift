//
//  MemeCollectionViewController.swift
//
//  Created by Cody Fazio on 4/12/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Create array for saved Memes
    var memes: [Meme]!
    //Create bar button for addding new Memes
    var addMemeButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        //Update the memes array to update view
        updateMemes()
        //Add attributes and link via segue to Meme Editor
        addMemeButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MemeCollectionViewController.createMeme))
        //Display addMemeButton
        self.navigationItem.rightBarButtonItem = addMemeButton
    }
    
    func viewWillAppear() {
        //Update the memes array to update view
        updateMemes()
    }
    
    //Pass in number of memes in array
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    //Create individual cells for view
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.item]
        let imageView = UIImageView(image: meme.image)
        cell.backgroundView = imageView
        return cell
    }
    
    //Segue to detail view when meme is selected
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        detailController.meme = self.memes[indexPath.item]
        detailController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    //Begin segue to Meme Editor
    func createMeme() {
        self.dismissViewControllerAnimated(true, completion: nil)
        tabBarController?.hidesBottomBarWhenPushed = true
        self.performSegueWithIdentifier("createMeme", sender: self)
    }
    
    //Update Memes array in AppDelegate
    func updateMemes(){
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        memes = applicationDelegate.memes
    }
}